import 'package:equatable/equatable.dart';

/// Représente le comptage de pas pour un jour donné.
class DailySteps extends Equatable {
  const DailySteps({
    required this.date,
    required this.stepCount,
    this.goalSteps = 8000,
  });

  /// Date du jour (heure ignorée — clé unique yyyy-MM-dd).
  final DateTime date;
  final int stepCount;
  final int goalSteps;

  /// Calories estimées : pas × 0.04 kcal (approximation adulte 70 kg).
  double get caloriesEstimated => stepCount * 0.04;

  /// Distance estimée en mètres : pas × 0.762 m (foulée moyenne adulte).
  double get distanceMeters => stepCount * 0.762;

  /// Distance en kilomètres.
  double get distanceKm => distanceMeters / 1000;

  /// Minutes actives estimées : pas / 100.
  int get activeMinutesEstimated => stepCount ~/ 100;

  /// Progression vers l'objectif (0.0 → 1.0, peut dépasser 1.0).
  double get progressRatio => goalSteps > 0 ? stepCount / goalSteps : 0.0;

  bool get goalReached => stepCount >= goalSteps;

  DailySteps copyWith({
    DateTime? date,
    int? stepCount,
    int? goalSteps,
  }) =>
      DailySteps(
        date: date ?? this.date,
        stepCount: stepCount ?? this.stepCount,
        goalSteps: goalSteps ?? this.goalSteps,
      );

  Map<String, dynamic> toMap() => {
        'date': _dateKey(date),
        'step_count': stepCount,
        'goal_steps': goalSteps,
        'created_at': date.millisecondsSinceEpoch,
      };

  factory DailySteps.fromMap(Map<String, dynamic> map) => DailySteps(
        date: DateTime.parse(map['date'] as String),
        stepCount: (map['step_count'] as int?) ?? 0,
        goalSteps: (map['goal_steps'] as int?) ?? 8000,
      );

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [date, stepCount, goalSteps];
}
