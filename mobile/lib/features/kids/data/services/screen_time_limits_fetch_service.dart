import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/harmony_services.dart';
import 'kids_storage.dart';

// ─── Modèles minimaux côté enfant ────────────────────────────────────────────

class KidsScreenTimeLimit {
  const KidsScreenTimeLimit({
    required this.id,
    required this.scope,
    required this.limitSeconds,
    this.packageName,
  });

  final String id;
  final String scope;
  final int limitSeconds;
  final String? packageName;

  factory KidsScreenTimeLimit.fromJson(Map<String, dynamic> j) =>
      KidsScreenTimeLimit(
        id: j['id'] as String,
        scope: j['scope'] as String,
        limitSeconds: (j['limit_seconds'] as num).toInt(),
        packageName: j['package_name'] as String?,
      );
}

class KidsScreenTimeStatus {
  const KidsScreenTimeStatus({
    required this.scope,
    required this.limitSeconds,
    required this.usedSeconds,
    required this.remainingSeconds,
    required this.exceeded,
    this.packageName,
  });

  final String scope;
  final int limitSeconds;
  final int usedSeconds;
  final int remainingSeconds;
  final bool exceeded;
  final String? packageName;

  factory KidsScreenTimeStatus.fromJson(Map<String, dynamic> j) =>
      KidsScreenTimeStatus(
        scope: j['scope'] as String,
        limitSeconds: (j['limit_seconds'] as num).toInt(),
        usedSeconds: (j['used_seconds'] as num).toInt(),
        remainingSeconds: (j['remaining_seconds'] as num).toInt(),
        exceeded: j['exceeded'] as bool,
        packageName: j['package_name'] as String?,
      );
}

// ─── Service ─────────────────────────────────────────────────────────────────

/// Récupère périodiquement les limites et le statut du jour côté enfant.
/// Ce sprint : log uniquement — le blocage natif sera implémenté au sprint 5C.
class ScreenTimeLimitsFetchService {
  ScreenTimeLimitsFetchService();

  static final ScreenTimeLimitsFetchService instance =
      ScreenTimeLimitsFetchService();

  Timer? _timer;

  List<KidsScreenTimeLimit> _cachedLimits = [];
  List<KidsScreenTimeStatus> _cachedStatus = [];

  // Accès en lecture pour le sprint 5C (blocage natif)
  List<KidsScreenTimeLimit> get cachedLimits => List.unmodifiable(_cachedLimits);
  List<KidsScreenTimeStatus> get cachedStatus => List.unmodifiable(_cachedStatus);

  /// Démarre le polling toutes les 5 minutes.
  void start() {
    _fetchAndLog();
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _fetchAndLog(),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchAndLog() async {
    final childId = await KidsStorage.instance.getChildId();
    if (childId == null) return;

    try {
      final limits = await fetchLimits(childId);
      _cachedLimits = limits;
      debugPrint(
        '[ScreenTimeLimitsFetchService] ${limits.length} limite(s) récupérée(s)',
      );
      for (final l in limits) {
        debugPrint(
            '  scope=${l.scope} pkg=${l.packageName} limit=${l.limitSeconds}s');
      }
    } catch (e) {
      debugPrint('[ScreenTimeLimitsFetchService] erreur getLimits: $e');
    }

    try {
      final status = await fetchStatus(childId);
      _cachedStatus = status;
      debugPrint('[ScreenTimeLimitsFetchService] statut du jour:');
      for (final s in status) {
        final tag = s.exceeded ? '⚠ DÉPASSÉ' : 'ok';
        debugPrint(
          '  scope=${s.scope} pkg=${s.packageName} '
          'used=${s.usedSeconds}s / limit=${s.limitSeconds}s → $tag',
        );
      }
    } catch (e) {
      debugPrint('[ScreenTimeLimitsFetchService] erreur getStatus: $e');
    }
  }

  /// Surchargeable dans les tests.
  Future<List<KidsScreenTimeLimit>> fetchLimits(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<dynamic>('/api/v1/screen-time/limits/$childId');
    return (response.data as List<dynamic>)
        .map((e) => KidsScreenTimeLimit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Surchargeable dans les tests.
  Future<List<KidsScreenTimeStatus>> fetchStatus(String childId) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final response = await HarmonyServices.dioClient.instance.get<dynamic>(
      '/api/v1/screen-time/status/$childId',
      queryParameters: {'date': dateStr},
    );
    return (response.data as List<dynamic>)
        .map((e) => KidsScreenTimeStatus.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
