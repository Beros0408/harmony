import '../models/safe_zone.dart';

abstract interface class ISafeZoneRepository {
  Future<List<SafeZone>> getAll();
  Future<SafeZone?> getById(String id);
  Future<List<SafeZone>> getActiveZonesFor(String childId, DateTime at);
  Future<void> add(SafeZone zone);
  Future<void> update(SafeZone zone);
  Future<void> delete(String id);
  Future<void> seed(List<SafeZone> zones);
}
