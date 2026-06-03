import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/harmony_services.dart';
import 'kids_storage.dart';
import 'usage_stats_service.dart';

/// Remonte l'usage applicatif journalier au backend (POST /api/v1/screen-time/usage).
/// Déclenchement : immédiatement au démarrage + toutes les 30 minutes tant que l'app est active.
/// La remontée est ignorée sans crash si la permission n'est pas accordée ou si le réseau est KO.
class ScreenTimeUploadService {
  ScreenTimeUploadService();
  static final ScreenTimeUploadService instance = ScreenTimeUploadService();

  static const Duration _interval = Duration(minutes: 30);

  Timer? _timer;

  /// Démarre le service. Idempotent si déjà en cours.
  Future<void> start() async {
    final granted = await UsageStatsService.instance.isPermissionGranted();
    if (!granted) return;

    // Remontée immédiate
    await _triggerUpload();

    // Remontée périodique
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => _triggerUpload());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _triggerUpload() async {
    final childId = await KidsStorage.instance.getChildId();
    if (childId == null) return;

    final entries = await UsageStatsService.instance.getDailyUsage();
    if (entries.isEmpty) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final batch = entries
        .map(
          (e) => {
            'package_name': e.packageName,
            'app_label': e.appLabel,
            'category': e.category,
            'duration_seconds': e.durationSeconds,
            'usage_date': dateStr,
          },
        )
        .toList();

    try {
      await uploadBatch(childId, batch);
      debugPrint('[ScreenTimeUpload] ${batch.length} entrées remontées pour $childId');
    } on DioException catch (e) {
      // Réseau indisponible → le prochain tick réessaiera
      debugPrint('[ScreenTimeUpload] réseau KO (${e.type}), retry dans $_interval');
    } catch (e) {
      debugPrint('[ScreenTimeUpload] erreur inattendue : $e');
    }
  }

  /// Appel réseau isolé — surchargeable dans les tests.
  Future<void> uploadBatch(String childId, List<Map<String, dynamic>> entries) async {
    await HarmonyServices.dioClient.instance.post<dynamic>(
      '/api/v1/screen-time/usage',
      data: {'child_id': childId, 'entries': entries},
    );
  }
}
