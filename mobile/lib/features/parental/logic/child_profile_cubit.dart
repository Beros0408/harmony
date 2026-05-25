import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/child_profile.dart';
import '../data/models/security_score.dart';
import '../data/repositories/i_child_profile_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

sealed class ChildProfileState extends Equatable {
  const ChildProfileState();
  @override
  List<Object?> get props => [];
}

final class ChildProfileLoading extends ChildProfileState {
  const ChildProfileLoading();
}

final class ChildProfileLoaded extends ChildProfileState {
  final List<ChildProfile> profiles;
  final Map<String, SecurityScore> scores;
  const ChildProfileLoaded({required this.profiles, this.scores = const {}});

  @override
  List<Object?> get props => [profiles, scores];
}

final class ChildProfileError extends ChildProfileState {
  final String message;
  const ChildProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class ChildProfileCubit extends Cubit<ChildProfileState> {
  ChildProfileCubit(this._repo) : super(const ChildProfileLoading());

  final IChildProfileRepository _repo;

  Future<void> load() async {
    emit(const ChildProfileLoading());
    try {
      final profiles = await _repo.getAll();
      emit(ChildProfileLoaded(profiles: profiles));
    } catch (e) {
      emit(ChildProfileError(e.toString()));
    }
  }

  Future<void> add(ChildProfile profile) async {
    await _repo.add(profile);
    await load();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await load();
  }

  void updateScores(Map<String, SecurityScore> scores) {
    final current = state;
    if (current is ChildProfileLoaded) {
      emit(ChildProfileLoaded(profiles: current.profiles, scores: scores));
    }
  }
}
