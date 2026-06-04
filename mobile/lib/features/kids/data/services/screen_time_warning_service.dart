import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screen_time_limits_fetch_service.dart';

// ─── Modèles ──────────────────────────────────────────────────────────────────

/// Avertissement calculé prêt à être envoyé en notification.
class WarningToSend {
  const WarningToSend({
    required this.scope,
    this.packageName,
    required this.thresholdSeconds,
  });

  final String scope;          // 'global' | 'app'
  final String? packageName;
  final int thresholdSeconds;  // 600, 300 ou 60
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Clé unique pour un couple (limite × seuil) — utilisée pour l'anti-spam.
String _warningKey(String scope, String? packageName, int threshold) =>
    '$scope|${packageName ?? ""}|$threshold';

/// Date du jour sous la forme 'yyyy-MM-dd', stable pour les comparaisons.
String _todayString(DateTime now) =>
    '${now.year}-${now.month.toString().padLeft(2, '0')}'
    '-${now.day.toString().padLeft(2, '0')}';

// ─── Service ──────────────────────────────────────────────────────────────────

/// Surveille les limites de temps d'écran et envoie des notifications locales
/// bienveillantes 10 min, 5 min et 1 min avant le blocage.
///
/// - Lit [ScreenTimeLimitsFetchService.cachedStatus] — zéro appel réseau.
/// - Anti-spam strict : chaque (limite × seuil) n'est notifié qu'une fois par jour.
/// - S'applique aux limites globales ET par application.
class ScreenTimeWarningService {
  ScreenTimeWarningService._internal(this._plugin);

  static final ScreenTimeWarningService instance =
      ScreenTimeWarningService._internal(FlutterLocalNotificationsPlugin());

  /// Constructeur d'injection pour les tests.
  @visibleForTesting
  factory ScreenTimeWarningService.forTest(
    FlutterLocalNotificationsPlugin plugin,
  ) =>
      ScreenTimeWarningService._internal(plugin);

  // ─── Constantes ────────────────────────────────────────────────────────────

  static const String _channelId = 'harmony_screen_time';
  static const String _channelName = 'Temps d\'écran';
  static const String _channelDesc =
      'Avertissements progressifs de temps d\'écran';

  /// Seuils surveillés (secondes restantes), ordre décroissant.
  static const List<int> thresholds = [600, 300, 60];

  // ─── État interne ──────────────────────────────────────────────────────────

  final FlutterLocalNotificationsPlugin _plugin;

  /// Anti-spam : warningKey → date 'yyyy-MM-dd' de la dernière notification.
  final Map<String, String> _notifiedDates = {};

  bool _initialized = false;
  Timer? _timer;

  // ─── Cycle de vie ──────────────────────────────────────────────────────────

  /// Initialise le canal de notification et demande la permission (Android 13+).
  /// Silencieux si la permission est refusée — les notifications disparaissent.
  Future<void> init() async {
    if (_initialized) return;

    await Permission.notification.request();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);

    // Canal non-urgent (importance default) pour ne pas anxiogener l'enfant.
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
    debugPrint('[ScreenTimeWarningService] initialisé');
  }

  /// Démarre la surveillance : 1 vérification immédiate + toutes les 60 s.
  void start() {
    _tick();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  // ─── Tick interne ──────────────────────────────────────────────────────────

  Future<void> _tick() async {
    final status = ScreenTimeLimitsFetchService.instance.cachedStatus;
    if (status.isEmpty) return;

    final today = _todayString(DateTime.now());
    final toSend = computeWarnings(status, today, _notifiedDates);

    for (final w in toSend) {
      // Marquer immédiatement comme "notifié" pour éviter les doublons même
      // en cas d'erreur d'envoi.
      _notifiedDates[_warningKey(w.scope, w.packageName, w.thresholdSeconds)] =
          today;
      if (_initialized) await _sendNotification(w);
    }
  }

  // ─── Logique pure (testable sans plugin) ──────────────────────────────────

  /// Calcule la liste des avertissements à envoyer.
  ///
  /// Règles :
  /// - Ignore les limites déjà dépassées ([KidsScreenTimeStatus.exceeded]).
  /// - Pour chaque seuil [thresholds], si [remainingSeconds] est strictement
  ///   inférieur au seuil et que le couple (limite × seuil) n'a pas encore été
  ///   notifié aujourd'hui, ajoute un [WarningToSend].
  /// - La mise à jour de [notifiedDates] est laissée à l'appelant pour
  ///   permettre des tests sans effet de bord.
  static List<WarningToSend> computeWarnings(
    List<KidsScreenTimeStatus> status,
    String today,
    Map<String, String> notifiedDates,
  ) {
    final result = <WarningToSend>[];

    for (final s in status) {
      if (s.exceeded) continue; // le blocage prend le relais

      for (final threshold in thresholds) {
        if (s.remainingSeconds >= threshold) continue; // pas encore sous le seuil

        final key = _warningKey(s.scope, s.packageName, threshold);
        if (notifiedDates[key] == today) continue; // déjà notifié ce jour

        result.add(WarningToSend(
          scope: s.scope,
          packageName: s.packageName,
          thresholdSeconds: threshold,
        ));
      }
    }
    return result;
  }

  // ─── Envoi des notifications ───────────────────────────────────────────────

  Future<void> _sendNotification(WarningToSend w) async {
    final id = _notifId(w.scope, w.packageName, w.thresholdSeconds);
    final title = buildTitle(w);
    final body = buildBody(w);

    try {
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
      debugPrint('[ScreenTimeWarningService] notif: $title — $body');
    } catch (e) {
      debugPrint('[ScreenTimeWarningService] erreur envoi notif: $e');
    }
  }

  // ─── Textes bienveillants ─────────────────────────────────────────────────

  /// Titre court de la notification — exposé pour les tests.
  @visibleForTesting
  static String buildTitle(WarningToSend w) {
    final minutes = w.thresholdSeconds ~/ 60;
    if (w.scope == 'global') {
      return 'Plus que $minutes minute${minutes > 1 ? "s" : ""} 🌙';
    }
    final appName = friendlyName(w.packageName);
    return 'Plus que $minutes minute${minutes > 1 ? "s" : ""} sur $appName 🌸';
  }

  /// Corps de la notification — exposé pour les tests.
  @visibleForTesting
  static String buildBody(WarningToSend w) {
    if (w.thresholdSeconds == 60) {
      return 'Encore 1 minute, puis ce sera l\'heure d\'une pause 🌙';
    }
    final minutes = w.thresholdSeconds ~/ 60;
    if (w.scope == 'global') {
      return 'Plus que $minutes minutes de temps d\'écran aujourd\'hui 🌙';
    }
    final appName = friendlyName(w.packageName);
    return 'Plus que $minutes minutes sur $appName aujourd\'hui 🌸';
  }

  /// Extrait un nom lisible depuis un package Android.
  /// 'com.instagram.android' → 'Instagram'. Exposé pour les tests.
  @visibleForTesting
  static String friendlyName(String? packageName) {
    if (packageName == null || packageName.isEmpty) return 'cette app';
    final parts = packageName.split('.');
    // Prendre l'avant-dernier segment : 'instagram' dans 'com.instagram.android'
    final candidate = parts.length >= 3
        ? parts[parts.length - 2]
        : parts.last;
    if (candidate.isEmpty) return packageName;
    return candidate[0].toUpperCase() + candidate.substring(1);
  }

  // ─── IDs de notification stables ─────────────────────────────────────────

  /// Génère un ID entier stable pour éviter d'empiler des notifications.
  /// Plage globale : 80060–80600. Plage par app : 70000–79999.
  static int _notifId(
    String scope,
    String? packageName,
    int thresholdSeconds,
  ) {
    if (scope == 'global') {
      switch (thresholdSeconds) {
        case 600:
          return 80600;
        case 300:
          return 80300;
        case 60:
          return 80060;
        default:
          return 80000 + thresholdSeconds;
      }
    }
    final pkg = packageName ?? '';
    final base = (pkg.hashCode.abs() % 10000) * 10;
    final offset = thresholdSeconds == 600
        ? 0
        : thresholdSeconds == 300
            ? 1
            : 2;
    return 70000 + base + offset;
  }
}
