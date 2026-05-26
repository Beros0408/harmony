import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/pedometer_service.dart';
import '../../domain/i_fitness_repository.dart';
import '../models/daily_steps.dart';
import '../models/workout_session.dart';

/// Implémentation production de IFitnessRepository.
/// Stratégie : pedometer → si indisponible → données mock (émulateur).
/// Persistance SQLCipher pour daily_steps et workout_sessions.
class NativeFitnessRepository implements IFitnessRepository {
  NativeFitnessRepository({PedometerService? pedometerService})
      : _pedometer = pedometerService ?? PedometerService.instance;

  final PedometerService _pedometer;
  static const _uuid = Uuid();

  static final NativeFitnessRepository instance = NativeFitnessRepository();

  // Objectif quotidien en cache (évite des lectures DB répétées)
  int _cachedGoal = 8000;

  // ─── Permissions ──────────────────────────────────────────────────────────

  @override
  Future<bool> hasActivityPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final status = await Permission.activityRecognition.status;
    // ignore: avoid_print
    print('[FITNESS-DEBUG] hasActivityPermission: ${status.name}');
    return status.isGranted;
  }

  @override
  Future<bool> requestActivityPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    // ignore: avoid_print
    print('[FITNESS-DEBUG] requestActivityPermission: affichage popup…');
    final status = await Permission.activityRecognition.request();
    // ignore: avoid_print
    print('[FITNESS-DEBUG] requestActivityPermission: ${status.name}');
    return status.isGranted;
  }

  // ─── Pas quotidiens ───────────────────────────────────────────────────────

  @override
  Future<DailySteps> getTodaySteps() async {
    final goal = await getGoal();
    final today = DateTime.now();
    final dateKey = _dateKey(today);

    // 1. Essayer pedometer
    final pedometerAvailable = await _pedometer.initialize();
    int stepCount;

    if (pedometerAvailable) {
      // Lire depuis DB (valeur mise à jour par le stream)
      final db = await DatabaseHelper.db;
      final rows = await db.query(
        'daily_steps',
        where: 'date = ?',
        whereArgs: [dateKey],
      );
      stepCount = rows.isNotEmpty
          ? (rows.first['step_count'] as int? ?? 0)
          : _pedometer.currentSessionSteps;
    } else {
      // 2. Fallback mock
      stepCount = _pedometer.getMockStepsForToday();
    }

    final steps = DailySteps(date: today, stepCount: stepCount, goalSteps: goal);
    // ignore: avoid_print
    print('[FITNESS-DEBUG] getTodaySteps: $stepCount pas (goal=$goal)');
    return steps;
  }

  @override
  Future<List<DailySteps>> getWeeklySteps() async {
    final goal = await getGoal();
    final db = await DatabaseHelper.db;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    final rows = await db.query(
      'daily_steps',
      where: 'created_at >= ?',
      whereArgs: [sevenDaysAgo.millisecondsSinceEpoch],
      orderBy: 'date ASC',
    );

    if (rows.isNotEmpty) {
      return rows.map((r) {
        final s = DailySteps.fromMap(Map<String, dynamic>.from(r));
        return s.copyWith(goalSteps: goal);
      }).toList();
    }

    // Aucune donnée en DB → données mock
    final mockSteps = _pedometer.getMockWeeklySteps();
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      return DailySteps(date: date, stepCount: mockSteps[i], goalSteps: goal);
    });
  }

  @override
  Future<void> saveTodaySteps(DailySteps steps) async {
    final db = await DatabaseHelper.db;
    final dateKey = _dateKey(steps.date);
    await db.insert(
      'daily_steps',
      {...steps.toMap(), 'date': dateKey},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // ignore: avoid_print
    print('[FITNESS-DEBUG] saveTodaySteps: $dateKey → ${steps.stepCount} pas');
  }

  // ─── Objectif ─────────────────────────────────────────────────────────────

  @override
  Future<int> getGoal() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(
      'daily_steps',
      columns: ['goal_steps'],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    _cachedGoal = rows.isNotEmpty ? (rows.first['goal_steps'] as int? ?? 8000) : 8000;
    return _cachedGoal;
  }

  @override
  Future<void> saveGoal(int goal) async {
    _cachedGoal = goal;
    final db = await DatabaseHelper.db;
    final today = DateTime.now();
    final dateKey = _dateKey(today);
    // Mettre à jour la ligne du jour si elle existe
    await db.update(
      'daily_steps',
      {'goal_steps': goal},
      where: 'date = ?',
      whereArgs: [dateKey],
    );
    // ignore: avoid_print
    print('[FITNESS-DEBUG] saveGoal: $goal pas/jour');
  }

  // ─── Séances ──────────────────────────────────────────────────────────────

  @override
  Future<WorkoutSession> startWorkout(WorkoutType type) async {
    final session = WorkoutSession(
      id: _uuid.v4(),
      type: type,
      startTime: DateTime.now(),
    );
    final db = await DatabaseHelper.db;
    await db.insert('workout_sessions', session.toMap());
    // ignore: avoid_print
    print('[FITNESS-DEBUG] startWorkout: ${type.name} → ${session.id}');
    return session;
  }

  @override
  Future<WorkoutSession> stopWorkout(String sessionId, {int steps = 0}) async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(
      'workout_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    if (rows.isEmpty) throw StateError('Session $sessionId introuvable');

    final session = WorkoutSession.fromMap(Map<String, dynamic>.from(rows.first));
    final finished = session.copyWith(
      endTime: DateTime.now(),
      stepsTotal: steps,
      distanceMeters: steps * 0.762,
    );
    await db.update(
      'workout_sessions',
      finished.toMap(),
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    // ignore: avoid_print
    print('[FITNESS-DEBUG] stopWorkout: ${session.type.name} → $steps pas');
    return finished;
  }

  @override
  Future<List<WorkoutSession>> getRecentWorkouts() async {
    final db = await DatabaseHelper.db;
    final cutoff =
        DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    final rows = await db.query(
      'workout_sessions',
      where: 'start_time >= ?',
      whereArgs: [cutoff],
      orderBy: 'start_time DESC',
      limit: 20,
    );
    return rows.map((r) => WorkoutSession.fromMap(Map<String, dynamic>.from(r))).toList();
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
