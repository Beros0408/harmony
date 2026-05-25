import '../models/geofence_event.dart';

abstract interface class IGeofenceEventRepository {
  Future<void> record(GeofenceEvent event);
  Future<List<GeofenceEvent>> getRecent(String childId, {int limit = 20});
}
