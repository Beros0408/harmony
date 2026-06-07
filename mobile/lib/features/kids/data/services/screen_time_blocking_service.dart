import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'screen_time_limits_fetch_service.dart';

// ─── Modèle de décision ───────────────────────────────────────────────────────

/// Résultat du calcul de blocage — testable sans dépendance native.
class BlockDecision {
  const BlockDecision({
    required this.globalBlocked,
    required this.blockedPackages,
  });

  /// Quota quotidien global dépassé → bloquer toutes les apps hors liste blanche.
  final bool globalBlocked;

  /// Packages dont la limite individuelle est dépassée.
  final List<String> blockedPackages;

  bool get isEmpty => !globalBlocked && blockedPackages.isEmpty;
}

// ─── Service ─────────────────────────────────────────────────────────────────

/// Pousse la liste de blocage vers [HarmonyScreenTimeService] (Kotlin) toutes les 30 s.
/// Source de vérité : [ScreenTimeLimitsFetchService.cachedStatus].
///
/// Démarré dans main_kids.dart dès que l'enfant est appairé.
/// Les appels MethodChannel échouent silencieusement si le service d'accessibilité
/// n'est pas activé — aucun crash.
class ScreenTimeBlockingService {
  ScreenTimeBlockingService();
  static final ScreenTimeBlockingService instance = ScreenTimeBlockingService();

  static const _channel = MethodChannel('harmony/screen_time_blocking');

  /// Packages jamais bloqués côté Flutter — miroir de NEVER_BLOCK dans HarmonyScreenTimeService.kt.
  /// Inclut les launchers et apps système critiques pour éviter de bricker l'appareil.
  static const Set<String> neverBlock = {
    'com.kimiacare.app',
    'android',
    'com.android.systemui',
    'com.android.settings',
    'com.google.android.dialer',
    'com.android.phone',
    'com.android.emergency',
    'com.samsung.android.dialer',
    'com.google.android.packageinstaller',
    'com.android.packageinstaller',
    'com.google.android.permissioncontroller',
    'com.android.launcher',
    'com.android.launcher2',
    'com.android.launcher3',
    'com.google.android.apps.nexuslauncher',
    'com.sec.android.app.launcher',
    'com.huawei.android.launcher',
    'com.miui.home',
    'com.oneplus.launcher',
    'com.bbk.launcher2',
    'com.oppo.launcher',
  };

  Timer? _timer;

  // Pause activée à distance par le parent (Sprint 5D-3) — indépendante des quotas
  bool _isRemotelyPaused = false;

  bool get isRemotelyPaused => _isRemotelyPaused;

  /// Démarre le push périodique (toutes les 30 s).
  void start() {
    _pushBlockList();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _pushBlockList());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Rafraîchissement explicite — appelé au retour au premier plan.
  Future<void> refresh() => _pushBlockList();

  /// Active la pause à distance — notifie Kotlin pour affichage immédiat de l'overlay.
  Future<void> activateRemotePause() async {
    _isRemotelyPaused = true;
    try {
      await _channel.invokeMethod<void>('setRemotePause', {'paused': true});
      debugPrint('[ScreenTimeBlockingService] pause distante activée');
    } catch (e) {
      debugPrint('[ScreenTimeBlockingService] setRemotePause(true) silencieux: $e');
    }
  }

  /// Lève la pause à distance — retire l'overlay si aucun quota n'est dépassé.
  Future<void> deactivateRemotePause() async {
    _isRemotelyPaused = false;
    try {
      await _channel.invokeMethod<void>('setRemotePause', {'paused': false});
      debugPrint('[ScreenTimeBlockingService] pause distante levée');
    } catch (e) {
      debugPrint('[ScreenTimeBlockingService] setRemotePause(false) silencieux: $e');
    }
  }

  // ─── Logique de décision (testable) ────────────────────────────────────────

  /// Calcule la décision de blocage depuis la liste de statuts.
  /// Méthode virtuelle pour faciliter les stubs de test.
  BlockDecision computeBlockDecision(List<KidsScreenTimeStatus> status) {
    bool globalBlocked = false;
    final blocked = <String>[];

    for (final entry in status) {
      if (!entry.exceeded) continue;
      if (entry.scope == 'global') {
        globalBlocked = true;
      } else if (entry.scope == 'app' && entry.packageName != null) {
        blocked.add(entry.packageName!);
      }
    }

    return BlockDecision(
      globalBlocked: globalBlocked,
      blockedPackages: blocked,
    );
  }

  /// Détermine si un package doit être bloqué, liste blanche incluse.
  static bool shouldBlock(String packageName, BlockDecision decision) {
    if (neverBlock.contains(packageName)) return false;
    if (decision.blockedPackages.contains(packageName)) return true;
    if (decision.globalBlocked) return true;
    return false;
  }

  // ─── Push vers Kotlin ──────────────────────────────────────────────────────

  Future<void> _pushBlockList() async {
    final status   = ScreenTimeLimitsFetchService.instance.cachedStatus;
    final decision = computeBlockDecision(status);
    try {
      await _channel.invokeMethod<void>('updateBlockList', {
        'blocked_packages': decision.blockedPackages,
        'global_blocked': decision.globalBlocked,
      });
      debugPrint(
        '[ScreenTimeBlockingService] push: global=${decision.globalBlocked} '
        'packages=${decision.blockedPackages}',
      );
    } catch (e) {
      // Service d'accessibilité inactif ou plateforme non-Android — silencieux
      debugPrint('[ScreenTimeBlockingService] updateBlockList silencieux: $e');
    }
  }

  // ─── Permission accessibilité ───────────────────────────────────────────────

  Future<bool> isAccessibilityGranted() async {
    try {
      return await _channel.invokeMethod<bool>('isAccessibilityGranted') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestAccessibilitySettings() async {
    try {
      await _channel.invokeMethod<void>('requestAccessibilitySettings');
    } catch (_) {}
  }
}
