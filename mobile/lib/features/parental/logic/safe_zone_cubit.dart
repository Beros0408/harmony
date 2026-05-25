import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/safe_zone.dart';
import '../data/repositories/i_safe_zone_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

sealed class SafeZoneState extends Equatable {
  const SafeZoneState();
  @override
  List<Object?> get props => [];
}

final class SafeZoneLoading extends SafeZoneState {
  const SafeZoneLoading();
}

final class SafeZoneLoaded extends SafeZoneState {
  final List<SafeZone> zones;
  const SafeZoneLoaded(this.zones);

  @override
  List<Object?> get props => [zones];
}

final class SafeZoneError extends SafeZoneState {
  final String message;
  const SafeZoneError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class SafeZoneCubit extends Cubit<SafeZoneState> {
  SafeZoneCubit(this._repo) : super(const SafeZoneLoading());

  final ISafeZoneRepository _repo;

  Future<void> load() async {
    emit(const SafeZoneLoading());
    try {
      final zones = await _repo.getAll();
      emit(SafeZoneLoaded(zones));
    } catch (e) {
      emit(SafeZoneError(e.toString()));
    }
  }

  Future<void> addZone(SafeZone zone) async {
    await _repo.add(zone);
    await load();
  }

  Future<void> updateZone(SafeZone zone) async {
    await _repo.update(zone);
    await load();
  }

  Future<void> deleteZone(String id) async {
    await _repo.delete(id);
    await load();
  }
}
