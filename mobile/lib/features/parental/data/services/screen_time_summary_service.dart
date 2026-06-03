import '../../../../core/services/harmony_services.dart';

/// Appelle GET /api/v1/screen-time/usage/{child_id}/summary
/// pour récupérer le résumé du temps d'écran d'un enfant pour un jour donné.
class ScreenTimeSummaryService {
  ScreenTimeSummaryService();
  static final ScreenTimeSummaryService instance = ScreenTimeSummaryService();

  /// Retourne le résumé pour [childId] à la date [date] (défaut = aujourd'hui).
  /// Surchargeable dans les tests.
  Future<ScreenTimeSummary> fetchSummary(
    String childId, {
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final response = await HarmonyServices.dioClient.instance.get<Map<String, dynamic>>(
      '/api/v1/screen-time/usage/$childId/summary',
      queryParameters: {'date': dateStr},
    );

    return ScreenTimeSummary.fromJson(response.data!);
  }
}

// ─── Modèles ────────────────────────────────────────────────────────────────

class AppUsageEntry {
  const AppUsageEntry({
    required this.packageName,
    required this.durationSeconds,
    this.appLabel,
    this.category,
  });

  final String packageName;
  final String? appLabel;
  final String? category;
  final int durationSeconds;

  factory AppUsageEntry.fromJson(Map<String, dynamic> j) => AppUsageEntry(
        packageName: j['package_name'] as String,
        appLabel: j['app_label'] as String?,
        category: j['category'] as String?,
        durationSeconds: (j['duration_seconds'] as num).toInt(),
      );
}

class ScreenTimeSummary {
  const ScreenTimeSummary({
    required this.childId,
    required this.usageDate,
    required this.totalSeconds,
    required this.topApps,
    required this.totalByCategory,
  });

  final String childId;
  final String usageDate;
  final int totalSeconds;
  final List<AppUsageEntry> topApps;
  final Map<String, int> totalByCategory;

  factory ScreenTimeSummary.fromJson(Map<String, dynamic> j) => ScreenTimeSummary(
        childId: j['child_id'] as String,
        usageDate: j['usage_date'] as String,
        totalSeconds: (j['total_seconds'] as num).toInt(),
        topApps: (j['top_apps'] as List<dynamic>)
            .map((e) => AppUsageEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalByCategory: Map<String, int>.from(
          (j['total_by_category'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ),
        ),
      );
}
