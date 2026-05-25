import '../models/task_item.dart';

abstract interface class ITaskRepository {
  Future<List<TaskItem>> getAll();
  Future<List<TaskItem>> getTasksByQuadrant(EisenhowerQuadrant quadrant);
  Future<List<TaskItem>> getOverdueTasks();
  Future<List<TaskItem>> getTasksDueToday();
  Future<void> add(TaskItem task);
  Future<void> update(TaskItem task);
  Future<void> delete(String id);
  Future<void> toggleComplete(String id);
}
