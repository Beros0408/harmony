import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../data/models/location_point.dart';
import '../data/models/sos_alert.dart';
import '../data/repositories/i_location_repository.dart';
import '../data/repositories/i_sos_alert_repository.dart';
import '../data/services/i_location_service.dart';

// ─── State ───────────────────────────────────────────────────────────────────

sealed class SosState extends Equatable {
  const SosState();
  @override
  List<Object?> get props => [];
}

final class SosIdle extends SosState {
  const SosIdle();
}

final class SosActive extends SosState {
  final SosAlert alert;
  final Duration elapsed;
  const SosActive({required this.alert, this.elapsed = Duration.zero});

  SosActive copyWithElapsed(Duration elapsed) =>
      SosActive(alert: alert, elapsed: elapsed);

  @override
  List<Object?> get props => [alert, elapsed];
}

final class SosResolved extends SosState {
  const SosResolved();
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class SosCubit extends Cubit<SosState> {
  SosCubit(this._sosRepo, this._locationRepo, this._locationService)
      : super(const SosIdle());

  final ISosAlertRepository _sosRepo;
  final ILocationRepository _locationRepo;
  final ILocationService _locationService;

  static const _uuid = Uuid();
  static const _callDelay = Duration(minutes: 2);

  Timer? _timer;
  int _secondsElapsed = 0;

  Future<void> trigger({required String childName, String? childId}) async {
    final effectiveChildId = childId ?? 'current';

    // Récupère la dernière position connue ou utilise 0,0 si introuvable
    LocationPoint? location = await _locationRepo.getLatest(effectiveChildId);
    location ??= await _locationService.getCurrentPosition(effectiveChildId);
    location ??= LocationPoint(
      id: _uuid.v4(),
      childId: effectiveChildId,
      latitude: 0,
      longitude: 0,
      accuracy: 999,
      timestamp: DateTime.now(),
    );

    final alert = SosAlert(
      id: _uuid.v4(),
      childId: effectiveChildId,
      childName: childName,
      timestamp: DateTime.now(),
      location: location,
      status: SosStatus.active,
    );

    await _sosRepo.trigger(alert);
    emit(SosActive(alert: alert));
    _startTimer(alert);
  }

  void _startTimer(SosAlert alert) {
    _secondsElapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _secondsElapsed++;
      emit(SosActive(
        alert: alert,
        elapsed: Duration(seconds: _secondsElapsed),
      ),);
      // Après 2 minutes sans acknowledge → appel 112 délégué à la UI
    });
  }

  Future<void> cancel(String alertId) async {
    _timer?.cancel();
    await _sosRepo.resolve(alertId);
    emit(const SosResolved());
    await Future<void>.delayed(const Duration(seconds: 1));
    emit(const SosIdle());
  }

  Duration get callDelay => _callDelay;

  @override
  Future<void> close() async {
    _timer?.cancel();
    return super.close();
  }
}
