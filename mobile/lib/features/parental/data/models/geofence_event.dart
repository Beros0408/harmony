import 'package:equatable/equatable.dart';
import 'location_point.dart';

enum GeofenceEventType { entry, exit }

class GeofenceEvent extends Equatable {
  final String id;
  final String childId;
  final String zoneId;
  final String zoneName;
  final GeofenceEventType type;
  final DateTime timestamp;
  final LocationPoint location;

  const GeofenceEvent({
    required this.id,
    required this.childId,
    required this.zoneId,
    required this.zoneName,
    required this.type,
    required this.timestamp,
    required this.location,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'child_id': childId,
        'zone_id': zoneId,
        'zone_name': zoneName,
        'type': type.index,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'accuracy': location.accuracy,
      };

  factory GeofenceEvent.fromMap(Map<String, dynamic> map) => GeofenceEvent(
        id: map['id'] as String,
        childId: map['child_id'] as String,
        zoneId: map['zone_id'] as String,
        zoneName: map['zone_name'] as String,
        type: GeofenceEventType.values[map['type'] as int],
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        location: LocationPoint(
          id: 'geo_${map['id']}',
          childId: map['child_id'] as String,
          latitude: (map['latitude'] as num).toDouble(),
          longitude: (map['longitude'] as num).toDouble(),
          accuracy: (map['accuracy'] as num).toDouble(),
          timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        ),
      );

  @override
  List<Object?> get props => [id, childId, zoneId, type, timestamp];
}
