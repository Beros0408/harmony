import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  final String id;
  final String childId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final int? batteryLevel;

  const LocationPoint({
    required this.id,
    required this.childId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.batteryLevel,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'child_id': childId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'battery_level': batteryLevel,
      };

  factory LocationPoint.fromMap(Map<String, dynamic> map) => LocationPoint(
        id: map['id'] as String,
        childId: map['child_id'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        accuracy: (map['accuracy'] as num).toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        batteryLevel: map['battery_level'] as int?,
      );

  // Désérialise un point venant du backend (recorded_at en UTC → heure locale).
  factory LocationPoint.fromJson(Map<String, dynamic> json) => LocationPoint(
        id: json['id'] as String,
        childId: json['child_id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.parse(json['recorded_at'] as String).toLocal(),
      );

  @override
  List<Object?> get props => [id, childId, latitude, longitude, accuracy, timestamp, batteryLevel];
}
