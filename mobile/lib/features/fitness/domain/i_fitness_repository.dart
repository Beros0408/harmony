import '../data/models/daily_steps.dart';
import '../data/models/workout_session.dart';

abstract interface class IFitnessRepository {
  /// Vérifie si la permission ACTIVITY_RECOGNITION est accordée.
  Future<bool> hasActivityPermission();

  /// Demande la permission ACTIVITY_RECOGNITION au runtime.
  Future<bool> requestActivityPermission();

  /// Retourne les pas du jour courant (live via pedometer ou mock).
  Future<DailySteps> getTodaySteps();

  /// Retourne les pas des 7 derniers jours (du plus ancien au plus récent).
  Future<List<DailySteps>> getWeeklySteps();

  /// Sauvegarde ou met à jour les pas du jour.
  Future<void> saveTodaySteps(DailySteps steps);

  /// Retourne l'objectif quotidien sauvegardé.
  Future<int> getGoal();

  /// Sauvegarde l'objectif quotidien.
  Future<void> saveGoal(int goal);

  /// Démarre une nouvelle séance.
  Future<WorkoutSession> startWorkout(WorkoutType type);

  /// Termine la séance en cours.
  Future<WorkoutSession> stopWorkout(String sessionId, {int steps = 0});

  /// Retourne les séances des 30 derniers jours.
  Future<List<WorkoutSession>> getRecentWorkouts();
}
