import 'package:equatable/equatable.dart';

enum WorkoutType { walking, running, cycling }

extension WorkoutTypeX on WorkoutType {
  String get displayName => switch (this) {
        WorkoutType.walking => 'Marche',
        WorkoutType.running => 'Course',
        WorkoutType.cycling => 'Vélo',
      };
}

/// Représente une séance d'entraînement horodatée.
class WorkoutSession extends Equatable {
  const WorkoutSession({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    this.stepsTotal = 0,
    this.distanceMeters = 0.0,
    this.averageHeartRate,
  });

  final String id;
  final WorkoutType type;
  final DateTime startTime;
  final DateTime? endTime;
  final int stepsTotal;
  final double distanceMeters;
  final int? averageHeartRate;

  bool get isActive => endTime == null;

  /// Durée de la séance, ou durée en cours si non terminée.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  double get distanceKm => distanceMeters / 1000;

  WorkoutSession copyWith({
    String? id,
    WorkoutType? type,
    DateTime? startTime,
    DateTime? endTime,
    int? stepsTotal,
    double? distanceMeters,
    int? averageHeartRate,
  }) =>
      WorkoutSession(
        id: id ?? this.id,
        type: type ?? this.type,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        stepsTotal: stepsTotal ?? this.stepsTotal,
        distanceMeters: distanceMeters ?? this.distanceMeters,
        averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'start_time': startTime.millisecondsSinceEpoch,
        'end_time': endTime?.millisecondsSinceEpoch,
        'steps_total': stepsTotal,
        'distance_meters': distanceMeters,
        'avg_heart_rate': averageHeartRate,
      };

  factory WorkoutSession.fromMap(Map<String, dynamic> map) => WorkoutSession(
        id: map['id'] as String,
        type: WorkoutType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => WorkoutType.walking,
        ),
        startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
        endTime: map['end_time'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int)
            : null,
        stepsTotal: (map['steps_total'] as int?) ?? 0,
        distanceMeters: (map['distance_meters'] as num?)?.toDouble() ?? 0.0,
        averageHeartRate: map['avg_heart_rate'] as int?,
      );

  @override
  List<Object?> get props => [id, type, startTime, endTime, stepsTotal];
}
