import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';
import 'package:harmony/features/call_filter/data/repositories/i_blacklist_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class BlacklistState extends Equatable {
  const BlacklistState({
    this.entries = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  final List<BlacklistEntry> entries;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  BlacklistState copyWith({
    List<BlacklistEntry>? entries,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      BlacklistState(
        entries: entries ?? this.entries,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [entries, searchQuery, isLoading, error];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class BlacklistCubit extends Cubit<BlacklistState> {
  BlacklistCubit(this._repo) : super(const BlacklistState());

  final IBlacklistRepository _repo;

  Future<void> loadEntries() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final entries = await _repo.getAll();
      emit(state.copyWith(entries: entries, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> search(String query) async {
    emit(state.copyWith(searchQuery: query, isLoading: true, clearError: true));
    try {
      final entries = await _repo.search(query);
      emit(state.copyWith(entries: entries, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addEntry(BlacklistEntry entry) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.add(entry);
      final entries = await _repo.search(state.searchQuery);
      emit(state.copyWith(entries: entries, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateEntry(BlacklistEntry entry) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.update(entry);
      final entries = await _repo.search(state.searchQuery);
      emit(state.copyWith(entries: entries, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteEntry(String id) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.delete(id);
      final entries = await _repo.search(state.searchQuery);
      emit(state.copyWith(entries: entries, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> clearAll() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repo.clear();
      emit(state.copyWith(entries: const [], isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
