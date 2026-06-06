import '../../../../core/services/harmony_services.dart';

// ─── Modèles ─────────────────────────────────────────────────────────────────

class FitnessDay {
  const FitnessDay({
    required this.activityDate,
    required this.steps,
    required this.activeMinutes,
    required this.distanceMeters,
  });

  final DateTime activityDate;
  final int steps;
  final int activeMinutes;
  final int distanceMeters;

  factory FitnessDay.fromJson(Map<String, dynamic> j) => FitnessDay(
        activityDate: DateTime.parse(j['activity_date'] as String),
        steps: (j['steps'] as num).toInt(),
        activeMinutes: (j['active_minutes'] as num).toInt(),
        distanceMeters: (j['distance_meters'] as num).toInt(),
      );
}

class FitnessSummary {
  const FitnessSummary({
    required this.childId,
    required this.days,
    required this.totalSteps,
    required this.averageStepsPerDay,
  });

  final String childId;
  final List<FitnessDay> days;
  final int totalSteps;
  final double averageStepsPerDay;

  factory FitnessSummary.fromJson(Map<String, dynamic> j) => FitnessSummary(
        childId: j['child_id'] as String,
        days: (j['days'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(FitnessDay.fromJson)
            .toList(),
        totalSteps: (j['total_steps'] as num).toInt(),
        averageStepsPerDay: (j['average_steps_per_day'] as num).toDouble(),
      );
}

// ─── Service ─────────────────────────────────────────────────────────────────

class FitnessSummaryService {
  FitnessSummaryService._();
  static final FitnessSummaryService instance = FitnessSummaryService._();

  Future<FitnessSummary> getSummary(String childId, {int days = 7}) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>(
      '/api/v1/fitness/summary/$childId',
      queryParameters: {'days': days},
    );
    return FitnessSummary.fromJson(response.data!);
  }
}
