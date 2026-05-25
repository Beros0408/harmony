import 'package:equatable/equatable.dart';
import 'location_point.dart';

enum SosStatus { active, acknowledged, resolved }

class SosAlert extends Equatable {
  final String id;
  final String childId;
  final String childName;
  final DateTime timestamp;
  final LocationPoint location;
  final SosStatus status;

  const SosAlert({
    required this.id,
    required this.childId,
    required this.childName,
    required this.timestamp,
    required this.location,
    required this.status,
  });

  SosAlert copyWith({SosStatus? status}) => SosAlert(
        id: id,
        childId: childId,
        childName: childName,
        timestamp: timestamp,
        location: location,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'child_id': childId,
        'child_name': childName,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
        'status': status.index,
      };

  factory SosAlert.fromMap(Map<String, dynamic> map) => SosAlert(
        id: map['id'] as String,
        childId: map['child_id'] as String,
        childName: map['child_name'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        status: SosStatus.values[map['status'] as int],
        location: LocationPoint(
          id: 'sos_${map['id']}',
          childId: map['child_id'] as String,
          latitude: (map['latitude'] as num).toDouble(),
          longitude: (map['longitude'] as num).toDouble(),
          accuracy: (map['accuracy'] as num).toDouble(),
          timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        ),
      );

  @override
  List<Object?> get props => [id, childId, timestamp, status];
}
