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
    this.bonusSeconds = 0,
  });

  final String scope;
  final int limitSeconds;
  // Bonus accordé par le parent pour ce jour (scope 'global' uniquement, 0 pour 'app')
  final int bonusSeconds;
  final int usedSeconds;
  final int remainingSeconds;
  final bool exceeded;
  final String? packageName;
  final String? appLabel;

  factory ScreenTimeStatusEntry.fromJson(Map<String, dynamic> j) =>
      ScreenTimeStatusEntry(
        scope: j['scope'] as String,
        limitSeconds: (j['limit_seconds'] as num).toInt(),
        bonusSeconds: (j['bonus_seconds'] as num? ?? 0).toInt(),
        usedSeconds: (j['used_seconds'] as num).toInt(),
        remainingSeconds: (j['remaining_seconds'] as num).toInt(),
        exceeded: j['exceeded'] as bool,
        packageName: j['package_name'] as String?,
        appLabel: j['app_label'] as String?,
      );
}

/// Bonus de temps d'écran accordé par le parent pour une journée donnée.
class ScreenTimeBonusEntry {
  const ScreenTimeBonusEntry({
    required this.childId,
    required this.bonusDate,
    required this.bonusSeconds,
  });

  final String childId;
  final String bonusDate;
  final int bonusSeconds;

  factory ScreenTimeBonusEntry.fromJson(Map<String, dynamic> j) =>
      ScreenTimeBonusEntry(
        childId: j['child_id'] as String,
        bonusDate: j['bonus_date'] as String,
        bonusSeconds: (j['bonus_seconds'] as num).toInt(),
      );
}

// ─── Service ─────────────────────────────────────────────────────────────────

/// Gère les limites et le bonus de temps d'écran côté parent.
class ScreenTimeLimitsService {
  ScreenTimeLimitsService();
  static final ScreenTimeLimitsService instance = ScreenTimeLimitsService();

  Future<List<ScreenTimeLimit>> getLimits(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<dynamic>('/api/v1/screen-time/limits/$childId');
    return parseLimitsBody(response.data);
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
    return parseStatusBody(response.data);
  }

  /// Retourne le bonus du jour (bonus_seconds=0 si aucun bonus accordé).
  Future<ScreenTimeBonusEntry> getBonus(String childId, {DateTime? date}) async {
    final d = date ?? DateTime.now();
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final response = await HarmonyServices.dioClient.instance.get<dynamic>(
      '/api/v1/screen-time/bonus/$childId',
      queryParameters: {'date': dateStr},
    );
    return ScreenTimeBonusEntry.fromJson(response.data as Map<String, dynamic>);
  }

  /// Définit ou ajuste le bonus pour la date donnée (upsert).
  Future<ScreenTimeBonusEntry> setBonus({
    required String childId,
    required String bonusDate,
    required int bonusSeconds,
  }) async {
    final body = <String, dynamic>{
      'child_id': childId,
      'bonus_date': bonusDate,
      'bonus_seconds': bonusSeconds,
    };
    final response = await HarmonyServices.dioClient.instance
        .put<Map<String, dynamic>>('/api/v1/screen-time/bonus', data: body);
    return ScreenTimeBonusEntry.fromJson(response.data!);
  }

  // ─── Parsing (extraits pour la testabilité) ──────────────────────────────

  // Dio peut retourner null pour response.data quand le backend renvoie 200 + "[]"
  // (liste vide) sur certaines versions/configs. On traite null et non-List comme
  // un succès à zéro élément plutôt que de lancer une TypeError.

  List<ScreenTimeLimit> parseLimitsBody(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .map((e) => ScreenTimeLimit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<ScreenTimeStatusEntry> parseStatusBody(dynamic data) {
    if (data == null || data is! List) return [];
    return data
        .map((e) => ScreenTimeStatusEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
