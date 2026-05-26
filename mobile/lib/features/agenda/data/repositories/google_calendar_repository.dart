import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis_auth/googleapis_auth.dart' as gauth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../models/agenda_event.dart';
import '../models/google_calendar_sync.dart';
import 'agenda_event_repository.dart';
import 'i_google_calendar_repository.dart';

/// Intègre Google Calendar via OAuth2 (google_sign_in + googleapis).
///
/// Mode dégradé : si google-services.json n'est pas configuré ou que
/// l'utilisateur n'a pas accordé les scopes, toutes les méthodes
/// échouent gracieusement sans crasher.
class GoogleCalendarRepository implements IGoogleCalendarRepository {
  GoogleCalendarRepository._();

  static final GoogleCalendarRepository instance = GoogleCalendarRepository._();

  static const _syncTable = 'google_calendar_sync';
  static const _uuid = Uuid();

  final _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/calendar'],
  );

  // ─── Auth helpers ────────────────────────────────────────────────────────────

  /// Crée un client HTTP authentifié à partir du token Google Sign-In actuel.
  Future<gauth.AuthClient?> _buildAuthClient() async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;
    final auth = await account.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) return null;

    return gauth.authenticatedClient(
      http.Client(),
      gauth.AccessCredentials(
        gauth.AccessToken(
          'Bearer',
          accessToken,
          // Le token Google expire dans ~1h ; l'expiry est utilisé uniquement
          // pour la validation locale, le retry est géré par le catch 401.
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        null,
        ['https://www.googleapis.com/auth/calendar'],
      ),
    );
  }

  // ─── IGoogleCalendarRepository ───────────────────────────────────────────────

  @override
  Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<GoogleCalendarSync?> getCurrentAccount() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_syncTable, limit: 1);
    if (rows.isEmpty) return null;
    return GoogleCalendarSync.fromMap(rows.first);
  }

  @override
  Future<void> signIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return;
    final db = await DatabaseHelper.db;
    final sync = GoogleCalendarSync(
      id: _uuid.v4(),
      accountEmail: account.email,
      lastSyncAt: DateTime.now(),
    );
    await db.delete(_syncTable);
    await db.insert(_syncTable, sync.toMap());
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final db = await DatabaseHelper.db;
    await db.delete(_syncTable);
  }

  // ─── Sync depuis Google Calendar ─────────────────────────────────────────────

  @override
  Future<List<AgendaEvent>> syncFromGoogle() async {
    if (!await isSignedIn()) return [];

    final authClient = await _buildAuthClient();
    if (authClient == null) return [];

    try {
      final calApi = gcal.CalendarApi(authClient);
      final currentSync = await getCurrentAccount();
      final syncToken = currentSync?.nextSyncToken;

      gcal.Events response;
      try {
        if (syncToken != null) {
          // Sync incrémental — ne récupère que les changements depuis le dernier sync
          response = await calApi.events.list('primary', syncToken: syncToken);
        } else {
          // Sync complète initiale — 30 jours passés + 90 jours futurs
          response = await calApi.events.list(
            'primary',
            timeMin: DateTime.now().subtract(const Duration(days: 30)).toUtc(),
            timeMax: DateTime.now().add(const Duration(days: 90)).toUtc(),
            singleEvents: true,
            orderBy: 'startTime',
          );
        }
      } on gcal.DetailedApiRequestError catch (e) {
        if (e.status == 410) {
          // syncToken invalidé (calendar modifié massivement) → reset + retry
          await _clearSyncToken();
          return syncFromGoogle();
        }
        rethrow;
      }

      // Récupérer toutes les pages
      final items = <gcal.Event>[...?response.items];
      var nextPage = response.nextPageToken;
      while (nextPage != null) {
        final page = await calApi.events.list('primary', pageToken: nextPage);
        items.addAll(page.items ?? []);
        nextPage = page.nextPageToken;
      }

      // Sauvegarder le nouveau syncToken pour la prochaine synchro
      if (response.nextSyncToken != null) {
        await _saveSyncToken(response.nextSyncToken!);
      }

      // Convertir les événements non annulés
      final agendaEvents = items
          .where((e) => e.status != 'cancelled')
          .where((e) => e.start != null)
          .map(_fromGoogleEvent)
          .toList();

      return agendaEvents;
    } finally {
      authClient.close();
    }
  }

  // ─── Sync vers Google Calendar ───────────────────────────────────────────────

  @override
  Future<void> syncToGoogle(AgendaEvent event) async {
    if (!await isSignedIn()) return;

    final authClient = await _buildAuthClient();
    if (authClient == null) return;

    try {
      final calApi = gcal.CalendarApi(authClient);
      final gEvent = _toGoogleEvent(event);

      if (event.googleEventId != null) {
        // Mise à jour d'un événement existant
        await calApi.events.patch(gEvent, 'primary', event.googleEventId!);
      } else {
        // Création d'un nouvel événement + sauvegarde du googleEventId local
        final created = await calApi.events.insert(gEvent, 'primary');
        if (created.id != null) {
          final updated = event.copyWith(googleEventId: created.id);
          await AgendaEventRepository.instance.update(updated);
        }
      }
    } finally {
      authClient.close();
    }
  }

  // ─── Helpers privés ──────────────────────────────────────────────────────────

  Future<void> _saveSyncToken(String token) async {
    final db = await DatabaseHelper.db;
    await db.rawUpdate(
      'UPDATE $_syncTable SET next_sync_token = ?, last_sync_at = ?',
      [token, DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<void> _clearSyncToken() async {
    final db = await DatabaseHelper.db;
    await db.rawUpdate(
      'UPDATE $_syncTable SET next_sync_token = NULL',
    );
  }

  /// Mapping gcal.Event → AgendaEvent.
  AgendaEvent _fromGoogleEvent(gcal.Event gEvent) {
    final startDate = gEvent.start?.dateTime?.toLocal() ??
        _parseDateOnly(gEvent.start?.date) ??
        DateTime.now();
    final endDate = gEvent.end?.dateTime?.toLocal() ??
        _parseDateOnly(gEvent.end?.date) ??
        startDate.add(const Duration(hours: 1));

    return AgendaEvent(
      id: _uuid.v4(),
      title: gEvent.summary ?? '(sans titre)',
      description: gEvent.description ?? '',
      category: EventCategory.other,
      startDate: startDate,
      endDate: endDate,
      location: gEvent.location,
      googleEventId: gEvent.id,
      color: categoryColor(EventCategory.other),
    );
  }

  /// Mapping AgendaEvent → gcal.Event.
  gcal.Event _toGoogleEvent(AgendaEvent event) => gcal.Event(
        summary: event.title,
        description: event.description.isEmpty ? null : event.description,
        location: event.location,
        start: gcal.EventDateTime(dateTime: event.startDate.toUtc()),
        end: gcal.EventDateTime(dateTime: event.endDate.toUtc()),
      );

  /// Parse une date "all-day" Google (format yyyy-MM-dd) en DateTime local.
  DateTime? _parseDateOnly(DateTime? date) => date;
}
