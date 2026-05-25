import '../models/location_point.dart';

abstract interface class ILocationRepository {
  Future<void> addPoint(LocationPoint point);
  Future<LocationPoint?> getLatest(String childId);
  Future<List<LocationPoint>> getHistory(String childId, DateTime from, DateTime to);
  Future<void> cleanupOlderThan(DateTime cutoff);
}
