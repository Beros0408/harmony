import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/location_point.dart';
import '../data/repositories/i_location_repository.dart';
import '../data/services/i_location_service.dart';

// ─── State ───────────────────────────────────────────────────────────────────

sealed class LocationState extends Equatable {
  const LocationState();
  @override
  List<Object?> get props => [];
}

final class LocationPermissionRequired extends LocationState {
  const LocationPermissionRequired();
}

final class LocationTracking extends LocationState {
  final Map<String, LocationPoint> latestByChild;
  const LocationTracking({this.latestByChild = const {}});

  @override
  List<Object?> get props => [latestByChild];
}

final class LocationError extends LocationState {
  final String message;
  const LocationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._service, this._repo) : super(const LocationPermissionRequired());

  final ILocationService _service;
  final ILocationRepository _repo;
  StreamSubscription<LocationPoint>? _sub;

  Future<void> initialize(List<String> childIds) async {
    final status = await _service.checkPermissions();
    if (status == LocationPermissionStatus.denied ||
        status == LocationPermissionStatus.permanentlyDenied) {
      emit(const LocationPermissionRequired());
      return;
    }

    // Charge les dernières positions connues depuis la base
    final latest = <String, LocationPoint>{};
    for (final id in childIds) {
      final point = await _repo.getLatest(id);
      if (point != null) latest[id] = point;
    }
    emit(LocationTracking(latestByChild: latest));

    await _service.startTracking();
    _sub = _service.positionStream('current').listen(_onNewPosition);
  }

  Future<void> requestPermissions(List<String> childIds) async {
    final status = await _service.requestPermissions();
    if (status != LocationPermissionStatus.denied &&
        status != LocationPermissionStatus.permanentlyDenied) {
      await initialize(childIds);
    } else {
      emit(const LocationError('Permission localisation refusée'));
    }
  }

  void _onNewPosition(LocationPoint point) {
    final current = state;
    if (current is LocationTracking) {
      final updated = Map<String, LocationPoint>.from(current.latestByChild);
      updated[point.childId] = point;
      emit(LocationTracking(latestByChild: updated));
      _repo.addPoint(point);
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    await _service.stopTracking();
    return super.close();
  }
}
