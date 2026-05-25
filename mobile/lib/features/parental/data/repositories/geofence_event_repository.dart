import '../../../../core/database/database_helper.dart';
import '../models/geofence_event.dart';
import 'i_geofence_event_repository.dart';

class GeofenceEventRepository implements IGeofenceEventRepository {
  GeofenceEventRepository._();

  static final GeofenceEventRepository instance = GeofenceEventRepository._();

  static const _table = 'geofence_events';

  @override
  Future<void> record(GeofenceEvent event) async {
    final db = await DatabaseHelper.db;
    await db.insert(_table, event.toMap());
  }

  @override
  Future<List<GeofenceEvent>> getRecent(String childId, {int limit = 20}) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(
      _table,
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(GeofenceEvent.fromMap).toList();
  }
}
