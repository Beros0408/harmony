import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../models/agenda_event.dart';
import '../models/google_calendar_sync.dart';
import 'i_google_calendar_repository.dart';

/// Intègre Google Calendar via OAuth2 (google_sign_in).
/// Sans google-services.json configuré, signIn() échoue gracieusement.
class GoogleCalendarRepository implements IGoogleCalendarRepository {
  GoogleCalendarRepository._();

  static final GoogleCalendarRepository instance = GoogleCalendarRepository._();

  static const _syncTable = 'google_calendar_sync';
  static const _uuid = Uuid();

  final _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/calendar'],
  );

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

  /// Retourne les événements importés depuis Google Calendar.
  /// MVP : retourne liste vide — implémentation complète en Phase 2.
  @override
  Future<List<AgendaEvent>> syncFromGoogle() async {
    if (!await isSignedIn()) return [];
    // TODO(sprint-5): appel CalendarApi.events.list avec nextSyncToken
    return [];
  }

  /// Pousse un événement local vers Google Calendar.
  @override
  Future<void> syncToGoogle(AgendaEvent event) async {
    if (!await isSignedIn()) return;
    // TODO(sprint-5): appel CalendarApi.events.insert / update
  }
}
