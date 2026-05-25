import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/task_item.dart';
import '../data/repositories/i_task_repository.dart';
import '../data/repositories/task_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

enum TaskStatus { loading, loaded, error }

class TaskState extends Equatable {
  const TaskState({
    this.status = TaskStatus.loaded,
    this.tasks = const [],
    this.activeQuadrant,
    this.error,
  });

  final TaskStatus status;
  final List<TaskItem> tasks;
  final EisenhowerQuadrant? activeQuadrant;
  final String? error;

  TaskState copyWith({
    TaskStatus? status,
    List<TaskItem>? tasks,
    EisenhowerQuadrant? activeQuadrant,
    bool clearQuadrant = false,
    String? error,
    bool clearError = false,
  }) =>
      TaskState(
        status: status ?? this.status,
        tasks: tasks ?? this.tasks,
        activeQuadrant:
            clearQuadrant ? null : (activeQuadrant ?? this.activeQuadrant),
        error: clearError ? null : (error ?? this.error),
      );

  /// Tâches groupées par quadrant Eisenhower.
  Map<EisenhowerQuadrant, List<TaskItem>> get byQuadrant {
    final map = <EisenhowerQuadrant, List<TaskItem>>{
      for (final q in EisenhowerQuadrant.values) q: [],
    };
    for (final task in tasks) {
      map[task.quadrant]!.add(task);
    }
    return map;
  }

  @override
  List<Object?> get props => [status, tasks, activeQuadrant, error];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({ITaskRepository? repository})
      : _repo = repository ?? TaskRepository.instance,
        super(const TaskState());

  final ITaskRepository _repo;

  Future<void> loadAll() async {
    emit(state.copyWith(status: TaskStatus.loading, clearError: true));
    try {
      final tasks = await _repo.getAll();
      emit(state.copyWith(status: TaskStatus.loaded, tasks: tasks));
    } catch (e) {
      emit(state.copyWith(status: TaskStatus.error, error: e.toString()));
    }
  }

  Future<void> loadByQuadrant(EisenhowerQuadrant quadrant) async {
    emit(state.copyWith(
      status: TaskStatus.loading,
      activeQuadrant: quadrant,
      clearError: true,
    ),);
    try {
      final tasks = await _repo.getTasksByQuadrant(quadrant);
      emit(state.copyWith(status: TaskStatus.loaded, tasks: tasks));
    } catch (e) {
      emit(state.copyWith(status: TaskStatus.error, error: e.toString()));
    }
  }

  Future<void> addTask(TaskItem task) async {
    try {
      await _repo.add(task);
      await _refresh();
    } catch (e) {
      emit(state.copyWith(status: TaskStatus.error, error: e.toString()));
    }
  }

  Future<void> updateTask(TaskItem task) async {
    try {
      await _repo.update(task);
      await _refresh();
    } catch (e) {
      emit(state.copyWith(status: TaskStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repo.delete(id);
      await _refresh();
    } catch (e) {
      emit(state.copyWith(status: TaskStatus.error, error: e.toString()));
    }
  }

  Future<void> toggleComplete(String id) async {
    try {
      await _repo.toggleComplete(id);
      await _refresh();
    } catch (e) {
      emit(state.copyWith(status: TaskStatus.error, error: e.toString()));
    }
  }

  Future<void> _refresh() async {
    if (state.activeQuadrant != null) {
      await loadByQuadrant(state.activeQuadrant!);
    } else {
      await loadAll();
    }
  }
}
