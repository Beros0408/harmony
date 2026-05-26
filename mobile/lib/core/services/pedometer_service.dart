import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';

/// Wrapper du package pedometer avec fallback gracieux (émulateur, iOS sans capteur).
/// Logs [PEDOMETER-DEBUG] pour faciliter le debug terrain.
class PedometerService {
  PedometerService._();
  static final PedometerService instance = PedometerService._();

  StreamSubscription<StepCount>? _subscription;
  int _sessionSteps = 0;
  int _baselineSteps = 0;
  bool _isAvailable = false;

  final StreamController<int> _stepsController =
      StreamController<int>.broadcast();

  Stream<int> get stepStream => _stepsController.stream;
  int get currentSessionSteps => _sessionSteps;

  /// Initialise l'écoute du pedometer. Retourne true si disponible.
  Future<bool> initialize() async {
    try {
      // ignore: avoid_print
      print('[PEDOMETER-DEBUG] PedometerService.initialize() — tentative…');
      _subscription = Pedometer.stepCountStream.listen(
        _onStep,
        onError: _onError,
        cancelOnError: false,
      );
      _isAvailable = true;
      // ignore: avoid_print
      print('[PEDOMETER-DEBUG] initialize() → pedometer disponible');
      return true;
    } on MissingPluginException catch (e) {
      // ignore: avoid_print
      print('[PEDOMETER-DEBUG] initialize() → MissingPluginException: $e → mode mock');
      _isAvailable = false;
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('[PEDOMETER-DEBUG] initialize() → EXCEPTION: $e → mode mock');
      _isAvailable = false;
      return false;
    }
  }

  void _onStep(StepCount event) {
    if (_baselineSteps == 0) _baselineSteps = event.steps;
    _sessionSteps = event.steps - _baselineSteps;
    // ignore: avoid_print
    print('[PEDOMETER-DEBUG] onStep: total=${event.steps}, session=$_sessionSteps');
    _stepsController.add(_sessionSteps);
  }

  void _onError(Object error) {
    // ignore: avoid_print
    print('[PEDOMETER-DEBUG] onError: $error → mode mock');
    _isAvailable = false;
  }

  /// Retourne le nombre de pas simulés (mode mock émulateur).
  /// Simule une progression réaliste sur la journée selon l'heure actuelle.
  int getMockStepsForToday() {
    final now = DateTime.now();
    final hourFraction = (now.hour + now.minute / 60.0) / 24.0;
    // Profil journalier : faible le matin, pic en journée
    final baseSteps = (4500 * hourFraction * (1 + 0.3 * hourFraction)).toInt();
    // ignore: avoid_print
    print('[PEDOMETER-DEBUG] getMockStepsForToday: $baseSteps (mock, heure=${now.hour}h)');
    return baseSteps.clamp(0, 12000);
  }

  /// Pas mock sur 7 jours (du plus ancien au plus récent).
  List<int> getMockWeeklySteps() {
    final today = getMockStepsForToday();
    return [5800, 7200, 6500, 8400, 6900, 9100, today];
  }

  bool get isAvailable => _isAvailable && !kIsWeb;

  void dispose() {
    _subscription?.cancel();
    _stepsController.close();
  }
}
