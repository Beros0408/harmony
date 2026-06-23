import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/child_profile.dart';
import '../data/models/security_score.dart';
import '../data/repositories/i_child_profile_repository.dart';
import '../data/services/family_api_service.dart';

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

  void updateScores(Map<String, SecurityScore> scores) {
    final current = state;
    if (current is ChildProfileLoaded) {
      emit(ChildProfileLoaded(profiles: current.profiles, scores: scores));
    }
  }

  /// Charge les enfants appairés depuis l'API Supabase.
  /// Fallback silencieux → ChildProfileLoaded([]) si réseau indisponible.
  /// Préserve [load()] (lecture locale) pour la compatibilité des tests.
  Future<void> loadFromApi([FamilyApiService? apiService]) async {
    emit(const ChildProfileLoading());
    try {
      final service = apiService ?? FamilyApiService.instance;
      final children = await service.getChildren();
      final profiles = children
          .map(
            (c) => ChildProfile(
              id: c.childId,
              name: c.fullName,
              age: 0, // non disponible dans Supabase — affiché sans âge dans l'UI
              avatarColor: _colorFromId(c.childId),
            ),
          )
          .toList();
      emit(ChildProfileLoaded(profiles: profiles));
    } catch (_) {
      // Réseau coupé ou erreur serveur : état vide plutôt que crash
      emit(const ChildProfileLoaded(profiles: []));
    }
  }

  /// Génère une couleur d'avatar déterministe à partir de l'UUID de l'enfant.
  static Color _colorFromId(String id) {
    const palette = [
      Color(0xFF3B82F6), // bleu
      Color(0xFF8B5CF6), // violet
      Color(0xFF10B981), // vert
      Color(0xFFEC4899), // rose
      Color(0xFFF59E0B), // ambre
      Color(0xFF06B6D4), // cyan
      Color(0xFFEF4444), // rouge
    ];
    return palette[id.hashCode.abs() % palette.length];
  }
}
