import '../../../../core/services/harmony_services.dart';

// ─── Modèles ────────────────────────────────────────────────────────────────

class ScreenTimeLimit {
  const ScreenTimeLimit({
    required this.id,
    required this.childId,
    required this.scope,
    required this.limitSeconds,
    this.packageName,
    this.appLabel,
  });

  final String id;
  final String childId;
  // 'global' | 'app'
  final String scope;
  final int limitSeconds;
  final String? packageName;
  final String? appLabel;

  factory ScreenTimeLimit.fromJson(Map<String, dynamic> j) => ScreenTimeLimit(
        id: j['id'] as String,
        childId: j['child_id'] as String,
        scope: j['scope'] as String,
        limitSeconds: (j['limit_seconds'] as num).toInt(),
        packageName: j['package_name'] as String?,
        appLabel: j['app_label'] as String?,
      );
}

class ScreenTimeStatusEntry {
  const ScreenTimeStatusEntry({
    required this.scope,
    required this.limitSeconds,
    required this.usedSeconds,
    required this.remainingSeconds,
    required this.exceeded,
    this.packageName,
    this.appLabel,
  });

  final String scope;
  final int limitSeconds;
  final int usedSeconds;
  final int remainingSeconds;
  final bool exceeded;
  final String? packageName;
  final String? appLabel;

  factory ScreenTimeStatusEntry.fromJson(Map<String, dynamic> j) =>
      ScreenTimeStatusEntry(
        scope: j['scope'] as String,
        limitSeconds: (j['limit_seconds'] as num).toInt(),
        usedSeconds: (j['used_seconds'] as num).toInt(),
        remainingSeconds: (j['remaining_seconds'] as num).toInt(),
        exceeded: j['exceeded'] as bool,
        packageName: j['package_name'] as String?,
        appLabel: j['app_label'] as String?,
      );
}

// ─── Service ─────────────────────────────────────────────────────────────────

/// Gère les limites de temps d'écran côté parent.
class ScreenTimeLimitsService {
  ScreenTimeLimitsService();
  static final ScreenTimeLimitsService instance = ScreenTimeLimitsService();

  Future<List<ScreenTimeLimit>> getLimits(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<dynamic>('/api/v1/screen-time/limits/$childId');
    return (response.data as List<dynamic>)
        .map((e) => ScreenTimeLimit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ScreenTimeLimit> setLimit({
    required String childId,
    required String scope,
    required int limitSeconds,
    String? packageName,
  }) async {
    final body = <String, dynamic>{
      'child_id': childId,
      'scope': scope,
      'limit_seconds': limitSeconds,
      if (packageName != null) 'package_name': packageName,
    };
    final response = await HarmonyServices.dioClient.instance
        .put<Map<String, dynamic>>('/api/v1/screen-time/limits', data: body);
    return ScreenTimeLimit.fromJson(response.data!);
  }

  Future<void> deleteLimit(String limitId) async {
    await HarmonyServices.dioClient.instance
        .delete<void>('/api/v1/screen-time/limits/$limitId');
  }

  Future<List<ScreenTimeStatusEntry>> getStatus(
    String childId, {
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final response = await HarmonyServices.dioClient.instance.get<dynamic>(
      '/api/v1/screen-time/status/$childId',
      queryParameters: {'date': dateStr},
    );
    return (response.data as List<dynamic>)
        .map((e) => ScreenTimeStatusEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
