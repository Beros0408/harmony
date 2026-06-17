import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/services/pedometer_service.dart';
import '../data/services/kids_storage.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class KidsActivityState {}

class KidsActivityInitial extends KidsActivityState {}

class KidsActivityLoading extends KidsActivityState {}

class KidsActivityLoaded extends KidsActivityState {
  KidsActivityLoaded({
    required this.steps,
    required this.goal,
    this.isPermissionDenied = false,
  });
  final int steps;
  final int goal;
  final bool isPermissionDenied;
}

class KidsActivityError extends KidsActivityState {
  KidsActivityError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class KidsActivityCubit extends Cubit<KidsActivityState> {
  KidsActivityCubit() : super(KidsActivityInitial());

  static const int _kGoal = 6000;

  StreamSubscription<StepCount>? _stepSub;

  // Total capteur (cumul depuis boot) au début de la journée en cours.
  // null = pas encore initialisé (nouveau jour ou premier lancement).
  int? _dailyOffset;

  Future<void> load() async {
    emit(KidsActivityLoading());

    // En debug, le capteur physique n'est pas disponible sur émulateur.
    // On émet directement une valeur mock réaliste pour valider l'UI.
    if (kDebugMode) {
      final mock = PedometerService.instance.getMockStepsForToday();
      if (!isClosed) emit(KidsActivityLoaded(steps: mock, goal: _kGoal));
      return;
    }

    final granted = await _checkPermission();
    if (!granted) {
      if (!isClosed) {
        emit(KidsActivityLoaded(steps: 0, goal: _kGoal, isPermissionDenied: true));
      }
      return;
    }

    await _startStream();
  }

  /// Vérifie et demande la permission ACTIVITY_RECOGNITION (Android 10+).
  /// Sur iOS et web, retourne true directement.
  Future<bool> _checkPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final status = await Permission.activityRecognition.status;
    if (status.isGranted) return true;
    final result = await Permission.activityRecognition.request();
    return result.isGranted;
  }

  /// Démarre l'écoute du capteur de pas et calcule les pas du jour.
  ///
  /// Logique offset :
  ///   - Si la date stockée == aujourd'hui → utilise l'offset stocké
  ///   - Sinon (nouveau jour ou premier lancement) → offset = total capteur
  ///     au premier événement reçu ; sauvegarde date + offset
  Future<void> _startStream() async {
    final today = _todayKey();
    final storedDate   = await KidsStorage.instance.getStepDate();
    final storedOffset = await KidsStorage.instance.getStepOffset();

    // Même journée : réutilise l'offset connu.
    // Nouveau jour ou premier lancement : _dailyOffset reste null,
    // sera initialisé au premier événement capteur.
    _dailyOffset = (storedDate == today) ? storedOffset : null;

    try {
      _stepSub = Pedometer.stepCountStream.listen(
        (StepCount event) async {
          final rawTotal = event.steps;

          if (_dailyOffset == null) {
            // Premier événement du jour : fige l'offset au total actuel.
            _dailyOffset = rawTotal;
            await KidsStorage.instance.saveStepOffset(rawTotal);
            await KidsStorage.instance.saveStepDate(today);
          }

          final daily = (rawTotal - _dailyOffset!).clamp(0, 999999);
          if (!isClosed) emit(KidsActivityLoaded(steps: daily, goal: _kGoal));
        },
        onError: (_) {
          // Capteur en erreur → affiche 0 sans crasher.
          if (!isClosed) emit(KidsActivityLoaded(steps: 0, goal: _kGoal));
        },
        cancelOnError: false,
      );
    } on MissingPluginException {
      // Plugin pedometer absent (build de test, simulateur iOS sans capteur).
      if (!isClosed) emit(KidsActivityLoaded(steps: 0, goal: _kGoal));
    } catch (_) {
      if (!isClosed) emit(KidsActivityLoaded(steps: 0, goal: _kGoal));
    }
  }

  /// Redemande la permission après un refus.
  /// Ouvre les paramètres système si la permission est définitivement refusée.
  Future<void> requestPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      await load();
      return;
    }
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      await load();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      if (!isClosed) {
        emit(KidsActivityLoaded(steps: 0, goal: _kGoal, isPermissionDenied: true));
      }
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<void> close() {
    _stepSub?.cancel();
    return super.close();
  }
}
