import '../../../../core/database/database_helper.dart';
import '../models/location_point.dart';
import 'i_location_repository.dart';

class LocationRepository implements ILocationRepository {
  LocationRepository._();

  static final LocationRepository instance = LocationRepository._();

  static const _table = 'location_points';

  @override
  Future<void> addPoint(LocationPoint point) async {
    final db = await DatabaseHelper.db;
    await db.insert(_table, point.toMap());
    // Nettoyage automatique des points de plus de 30 jours
    await cleanupOlderThan(DateTime.now().subtract(const Duration(days: 30)));
  }

  @override
  Future<LocationPoint?> getLatest(String childId) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(
      _table,
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : LocationPoint.fromMap(rows.first);
  }

  @override
  Future<List<LocationPoint>> getHistory(String childId, DateTime from, DateTime to) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(
      _table,
      where: 'child_id = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [childId, from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
      orderBy: 'timestamp ASC',
    );
    return rows.map(LocationPoint.fromMap).toList();
  }

  @override
  Future<void> cleanupOlderThan(DateTime cutoff) async {
    final db = await DatabaseHelper.db;
    await db.delete(
      _table,
      where: 'timestamp < ?',
      whereArgs: [cutoff.millisecondsSinceEpoch],
    );
  }
}
