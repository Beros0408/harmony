import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/daily_steps.dart';
import '../data/models/workout_session.dart';
import '../domain/i_fitness_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class FitnessState {}

class FitnessInitial extends FitnessState {}

class FitnessLoading extends FitnessState {}

class FitnessLoaded extends FitnessState {
  FitnessLoaded({
    required this.today,
    required this.weeklySteps,
    required this.goal,
    required this.recentWorkouts,
    this.activeWorkout,
  });

  final DailySteps today;
  final List<DailySteps> weeklySteps;
  final int goal;
  final List<WorkoutSession> recentWorkouts;
  final WorkoutSession? activeWorkout;
}

class FitnessPermissionDenied extends FitnessState {}

class FitnessError extends FitnessState {
  FitnessError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class FitnessCubit extends Cubit<FitnessState> {
  FitnessCubit({required IFitnessRepository repository})
      : _repository = repository,
        super(FitnessInitial());

  final IFitnessRepository _repository;
  WorkoutSession? _activeWorkout;

  Future<void> load() async {
    // ignore: avoid_print
    print('[FITNESS-DEBUG] FitnessCubit.load() start');
    emit(FitnessLoading());
    try {
      // Vérifie permission ACTIVITY_RECOGNITION (Android 10+)
      final hasPerm = await _repository.hasActivityPermission();
      // ignore: avoid_print
      print('[FITNESS-DEBUG] load() hasActivityPermission=$hasPerm');

      if (!hasPerm) {
        final granted = await _repository.requestActivityPermission();
        // ignore: avoid_print
        print('[FITNESS-DEBUG] load() requestActivityPermission → granted=$granted');
        if (!granted) {
          emit(FitnessPermissionDenied());
          return;
        }
      }

      final today = await _repository.getTodaySteps();
      final weekly = await _repository.getWeeklySteps();
      final goal = await _repository.getGoal();
      final workouts = await _repository.getRecentWorkouts();

      // ignore: avoid_print
      print('[FITNESS-DEBUG] load() → today=${today.stepCount} pas, weekly=${weekly.length} jours');

      emit(FitnessLoaded(
        today: today,
        weeklySteps: weekly,
        goal: goal,
        recentWorkouts: workouts,
        activeWorkout: _activeWorkout,
      ));
    } catch (e, st) {
      // ignore: avoid_print
      print('[FITNESS-DEBUG] load() EXCEPTION: $e\n$st');
      emit(FitnessError(e.toString()));
    }
  }

  /// Redemande la permission après refus.
  Future<void> requestActivityAccess() async {
    // ignore: avoid_print
    print('[FITNESS-DEBUG] requestActivityAccess()');
    final granted = await _repository.requestActivityPermission();
    if (granted) {
      await load();
    } else {
      emit(FitnessPermissionDenied());
    }
  }

  /// Démarre une séance d'entraînement.
  Future<void> startWorkout(WorkoutType type) async {
    // ignore: avoid_print
    print('[FITNESS-DEBUG] startWorkout(${type.name})');
    try {
      _activeWorkout = await _repository.startWorkout(type);
      await load();
    } catch (e) {
      // ignore: avoid_print
      print('[FITNESS-DEBUG] startWorkout EXCEPTION: $e');
      emit(FitnessError(e.toString()));
    }
  }

  /// Arrête la séance en cours.
  Future<void> stopWorkout({int steps = 0}) async {
    if (_activeWorkout == null) return;
    // ignore: avoid_print
    print('[FITNESS-DEBUG] stopWorkout(steps=$steps)');
    try {
      await _repository.stopWorkout(_activeWorkout!.id, steps: steps);
      _activeWorkout = null;
      await load();
    } catch (e) {
      // ignore: avoid_print
      print('[FITNESS-DEBUG] stopWorkout EXCEPTION: $e');
      emit(FitnessError(e.toString()));
    }
  }

  /// Met à jour l'objectif quotidien.
  Future<void> updateGoal(int goal) async {
    // ignore: avoid_print
    print('[FITNESS-DEBUG] updateGoal($goal)');
    try {
      await _repository.saveGoal(goal);
      await load();
    } catch (e) {
      // ignore: avoid_print
      print('[FITNESS-DEBUG] updateGoal EXCEPTION: $e');
    }
  }
}
