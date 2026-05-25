import '../../../../core/database/database_helper.dart';
import '../models/agenda_event.dart';
import 'i_agenda_event_repository.dart';

class AgendaEventRepository implements IAgendaEventRepository {
  AgendaEventRepository._();

  static final AgendaEventRepository instance = AgendaEventRepository._();

  static const _table = 'agenda_events';

  @override
  Future<List<AgendaEvent>> getEventsInRange(DateTime from, DateTime to) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(
      _table,
      where: 'start_date >= ? AND start_date <= ?',
      whereArgs: [
        from.millisecondsSinceEpoch,
        to.millisecondsSinceEpoch,
      ],
      orderBy: 'start_date ASC',
    );
    return rows.map(AgendaEvent.fromMap).toList();
  }

  @override
  Future<List<AgendaEvent>> getUpcomingEvents({int limit = 5}) async {
    final db = await DatabaseHelper.db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await db.query(
      _table,
      where: 'start_date >= ?',
      whereArgs: [now],
      orderBy: 'start_date ASC',
      limit: limit,
    );
    return rows.map(AgendaEvent.fromMap).toList();
  }

  @override
  Future<List<AgendaEvent>> getImportantEventsNow() async {
    final db = await DatabaseHelper.db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await db.query(
      _table,
      where: 'important = 1 AND start_date <= ? AND end_date >= ?',
      whereArgs: [now, now],
    );
    return rows.map(AgendaEvent.fromMap).toList();
  }

  @override
  Future<List<AgendaEvent>> searchEvents(String query) async {
    final db = await DatabaseHelper.db;
    final like = '%$query%';
    final rows = await db.query(
      _table,
      where: 'title LIKE ? OR description LIKE ? OR location LIKE ?',
      whereArgs: [like, like, like],
      orderBy: 'start_date ASC',
    );
    return rows.map(AgendaEvent.fromMap).toList();
  }

  @override
  Future<void> add(AgendaEvent event) async {
    final db = await DatabaseHelper.db;
    await db.insert(_table, event.toMap());
  }

  @override
  Future<void> update(AgendaEvent event) async {
    final db = await DatabaseHelper.db;
    await db.update(_table, event.toMap(), where: 'id = ?', whereArgs: [event.id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = await DatabaseHelper.db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<AgendaEvent?> getById(String id) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return AgendaEvent.fromMap(rows.first);
  }
}
