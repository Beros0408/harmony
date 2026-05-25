import '../../../../core/database/database_helper.dart';
import '../models/task_item.dart';
import 'i_task_repository.dart';

class TaskRepository implements ITaskRepository {
  TaskRepository._();

  static final TaskRepository instance = TaskRepository._();

  static const _table = 'agenda_tasks';

  @override
  Future<List<TaskItem>> getAll() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_table, orderBy: 'urgency DESC, importance DESC');
    return rows.map(TaskItem.fromMap).toList();
  }

  @override
  Future<List<TaskItem>> getTasksByQuadrant(EisenhowerQuadrant quadrant) async {
    final all = await getAll();
    return all.where((t) => t.quadrant == quadrant).toList();
  }

  @override
  Future<List<TaskItem>> getOverdueTasks() async {
    final db = await DatabaseHelper.db;
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await db.query(
      _table,
      where: 'deadline IS NOT NULL AND deadline < ? AND completed = 0',
      whereArgs: [now],
    );
    return rows.map(TaskItem.fromMap).toList();
  }

  @override
  Future<List<TaskItem>> getTasksDueToday() async {
    final db = await DatabaseHelper.db;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;
    final rows = await db.query(
      _table,
      where: 'deadline >= ? AND deadline <= ?',
      whereArgs: [startOfDay, endOfDay],
    );
    return rows.map(TaskItem.fromMap).toList();
  }

  @override
  Future<void> add(TaskItem task) async {
    final db = await DatabaseHelper.db;
    await db.insert(_table, task.toMap());
  }

  @override
  Future<void> update(TaskItem task) async {
    final db = await DatabaseHelper.db;
    await db.update(_table, task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  @override
  Future<void> delete(String id) async {
    final db = await DatabaseHelper.db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> toggleComplete(String id) async {
    final tasks = await getAll();
    final task = tasks.where((t) => t.id == id).firstOrNull;
    if (task == null) return;
    await update(task.copyWith(completed: !task.completed));
  }
}
