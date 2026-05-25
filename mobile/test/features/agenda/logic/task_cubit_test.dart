import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/agenda/data/models/task_item.dart';
import 'package:harmony/features/agenda/data/repositories/i_task_repository.dart';
import 'package:harmony/features/agenda/logic/task_cubit.dart';

// ─── Stub repo ────────────────────────────────────────────────────────────────

class _StubTaskRepo implements ITaskRepository {
  final List<TaskItem> _tasks = [];

  @override
  Future<List<TaskItem>> getAll() async => List.of(_tasks);

  @override
  Future<List<TaskItem>> getTasksByQuadrant(EisenhowerQuadrant quadrant) async =>
      _tasks.where((t) => t.quadrant == quadrant).toList();

  @override
  Future<List<TaskItem>> getOverdueTasks() async => [];

  @override
  Future<List<TaskItem>> getTasksDueToday() async => [];

  @override
  Future<void> add(TaskItem task) async => _tasks.add(task);

  @override
  Future<void> update(TaskItem task) async {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) _tasks[idx] = task;
  }

  @override
  Future<void> delete(String id) async => _tasks.removeWhere((t) => t.id == id);

  @override
  Future<void> toggleComplete(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    _tasks[idx] = _tasks[idx].copyWith(completed: !_tasks[idx].completed);
  }
}

TaskItem _task({
  String id = 't-001',
  String title = 'Task',
  TaskUrgency urgency = TaskUrgency.high,
  TaskImportance importance = TaskImportance.high,
}) =>
    TaskItem(id: id, title: title, urgency: urgency, importance: importance);

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _StubTaskRepo repo;
  late TaskCubit cubit;

  setUp(() {
    repo = _StubTaskRepo();
    cubit = TaskCubit(repository: repo);
  });

  tearDown(() => cubit.close());

  group('TaskCubit', () {
    test('initial state is loaded empty', () {
      expect(cubit.state.status, TaskStatus.loaded);
      expect(cubit.state.tasks, isEmpty);
    });

    test('loadAll emits all tasks', () async {
      repo._tasks.addAll([_task(id: 't-1'), _task(id: 't-2')]);
      await cubit.loadAll();
      expect(cubit.state.tasks, hasLength(2));
    });

    test('addTask persists and reloads', () async {
      await cubit.addTask(_task());
      expect(cubit.state.tasks, hasLength(1));
    });

    test('deleteTask removes from state', () async {
      final t = _task();
      repo._tasks.add(t);
      await cubit.loadAll();
      await cubit.deleteTask(t.id);
      expect(cubit.state.tasks, isEmpty);
    });

    test('toggleComplete flips completed flag', () async {
      final t = _task();
      repo._tasks.add(t);
      await cubit.loadAll();
      expect(cubit.state.tasks.first.completed, isFalse);
      await cubit.toggleComplete(t.id);
      expect(cubit.state.tasks.first.completed, isTrue);
    });

    test('loadByQuadrant filters correctly', () async {
      repo._tasks.addAll([
        _task(id: 't-1', urgency: TaskUrgency.high, importance: TaskImportance.high),
        _task(id: 't-2', urgency: TaskUrgency.low, importance: TaskImportance.low),
      ]);
      await cubit.loadByQuadrant(EisenhowerQuadrant.doFirst);
      expect(cubit.state.tasks, hasLength(1));
      expect(cubit.state.tasks.first.quadrant, EisenhowerQuadrant.doFirst);
    });

    test('byQuadrant map has all quadrants', () async {
      repo._tasks.add(_task());
      await cubit.loadAll();
      final map = cubit.state.byQuadrant;
      expect(map.keys, containsAll(EisenhowerQuadrant.values));
    });
  });
}
