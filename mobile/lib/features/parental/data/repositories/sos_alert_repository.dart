import '../../../../core/database/database_helper.dart';
import '../models/sos_alert.dart';
import 'i_sos_alert_repository.dart';

class SosAlertRepository implements ISosAlertRepository {
  SosAlertRepository._();

  static final SosAlertRepository instance = SosAlertRepository._();

  static const _table = 'sos_alerts';

  @override
  Future<void> trigger(SosAlert alert) async {
    final db = await DatabaseHelper.db;
    await db.insert(_table, alert.toMap());
  }

  @override
  Future<List<SosAlert>> getActive() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(
      _table,
      where: 'status = ?',
      whereArgs: [SosStatus.active.index],
      orderBy: 'timestamp DESC',
    );
    return rows.map(SosAlert.fromMap).toList();
  }

  @override
  Future<List<SosAlert>> getAll() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_table, orderBy: 'timestamp DESC');
    return rows.map(SosAlert.fromMap).toList();
  }

  @override
  Future<void> acknowledge(String alertId) async {
    final db = await DatabaseHelper.db;
    await db.update(
      _table,
      {'status': SosStatus.acknowledged.index},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  @override
  Future<void> resolve(String alertId) async {
    final db = await DatabaseHelper.db;
    await db.update(
      _table,
      {'status': SosStatus.resolved.index},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }
}
