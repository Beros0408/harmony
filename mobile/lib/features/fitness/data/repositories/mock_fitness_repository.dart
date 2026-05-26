import 'package:uuid/uuid.dart';

import '../../domain/i_fitness_repository.dart';
import '../models/daily_steps.dart';
import '../models/workout_session.dart';

/// Implémentation de test de IFitnessRepository.
/// 7 jours de données mockées, objectif configurable.
class MockFitnessRepository implements IFitnessRepository {
  MockFitnessRepository({
    int goal = 8000,
    bool permissionGranted = true,
    List<DailySteps>? weeklySteps,
  })  : _goal = goal,
        _permissionGranted = permissionGranted,
        _weeklySteps = weeklySteps ?? _defaultWeek(goal);

  int _goal;
  bool _permissionGranted;
  final List<DailySteps> _weeklySteps;
  final List<WorkoutSession> _sessions = [];
  static const _uuid = Uuid();

  static List<DailySteps> _defaultWeek(int goal) {
    final today = DateTime.now();
    final counts = [5800, 7200, 6500, 8400, 6900, 9100, 6247];
    return List.generate(7, (i) => DailySteps(
          date: today.subtract(Duration(days: 6 - i)),
          stepCount: counts[i],
          goalSteps: goal,
        ));
  }

  @override
  Future<bool> hasActivityPermission() async => _permissionGranted;

  @override
  Future<bool> requestActivityPermission() async {
    _permissionGranted = true;
    return true;
  }

  @override
  Future<DailySteps> getTodaySteps() async => _weeklySteps.last;

  @override
  Future<List<DailySteps>> getWeeklySteps() async => List.of(_weeklySteps);

  @override
  Future<void> saveTodaySteps(DailySteps steps) async {
    _weeklySteps[_weeklySteps.length - 1] = steps;
  }

  @override
  Future<int> getGoal() async => _goal;

  @override
  Future<void> saveGoal(int goal) async => _goal = goal;

  @override
  Future<WorkoutSession> startWorkout(WorkoutType type) async {
    final session = WorkoutSession(
      id: _uuid.v4(),
      type: type,
      startTime: DateTime.now(),
    );
    _sessions.add(session);
    return session;
  }

  @override
  Future<WorkoutSession> stopWorkout(String sessionId, {int steps = 0}) async {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx < 0) throw StateError('Session $sessionId introuvable');
    final finished = _sessions[idx].copyWith(
      endTime: DateTime.now(),
      stepsTotal: steps,
      distanceMeters: steps * 0.762,
    );
    _sessions[idx] = finished;
    return finished;
  }

  @override
  Future<List<WorkoutSession>> getRecentWorkouts() async => List.of(_sessions);
}
