import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/agenda_event.dart';
import '../data/models/google_calendar_sync.dart';
import '../data/repositories/google_calendar_repository.dart';
import '../data/repositories/i_google_calendar_repository.dart';

// ─── State ───────────────────────────────────────────────────────────────────

enum GoogleCalendarStatus {
  disconnected,
  connecting,
  connected,
  syncing,
  error,
}

class GoogleCalendarState extends Equatable {
  const GoogleCalendarState({
    this.status = GoogleCalendarStatus.disconnected,
    this.account,
    this.importedEvents = const [],
    this.error,
  });

  final GoogleCalendarStatus status;
  final GoogleCalendarSync? account;
  final List<AgendaEvent> importedEvents;
  final String? error;

  bool get isConnected =>
      status == GoogleCalendarStatus.connected ||
      status == GoogleCalendarStatus.syncing;

  GoogleCalendarState copyWith({
    GoogleCalendarStatus? status,
    GoogleCalendarSync? account,
    bool clearAccount = false,
    List<AgendaEvent>? importedEvents,
    String? error,
    bool clearError = false,
  }) =>
      GoogleCalendarState(
        status: status ?? this.status,
        account: clearAccount ? null : (account ?? this.account),
        importedEvents: importedEvents ?? this.importedEvents,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [status, account, importedEvents, error];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class GoogleCalendarCubit extends Cubit<GoogleCalendarState> {
  GoogleCalendarCubit({IGoogleCalendarRepository? repository})
      : _repo = repository ?? GoogleCalendarRepository.instance,
        super(const GoogleCalendarState());

  final IGoogleCalendarRepository _repo;

  /// Vérifie l'état de connexion au démarrage.
  Future<void> checkConnection() async {
    try {
      final isSignedIn = await _repo.isSignedIn();
      if (!isSignedIn) {
        emit(state.copyWith(
          status: GoogleCalendarStatus.disconnected,
          clearAccount: true,
        ),);
        return;
      }
      final account = await _repo.getCurrentAccount();
      emit(state.copyWith(
        status: GoogleCalendarStatus.connected,
        account: account,
      ),);
    } catch (e) {
      emit(state.copyWith(
        status: GoogleCalendarStatus.error,
        error: e.toString(),
      ),);
    }
  }

  Future<void> signIn() async {
    emit(state.copyWith(
      status: GoogleCalendarStatus.connecting,
      clearError: true,
    ),);
    try {
      await _repo.signIn();
      final account = await _repo.getCurrentAccount();
      emit(state.copyWith(
        status: GoogleCalendarStatus.connected,
        account: account,
      ),);
    } catch (e) {
      emit(state.copyWith(
        status: GoogleCalendarStatus.error,
        error: e.toString(),
      ),);
    }
  }

  Future<void> signOut() async {
    try {
      await _repo.signOut();
      emit(const GoogleCalendarState());
    } catch (e) {
      emit(state.copyWith(
        status: GoogleCalendarStatus.error,
        error: e.toString(),
      ),);
    }
  }

  Future<void> syncFromGoogle() async {
    if (!state.isConnected) return;
    emit(state.copyWith(status: GoogleCalendarStatus.syncing, clearError: true));
    try {
      final events = await _repo.syncFromGoogle();
      emit(state.copyWith(
        status: GoogleCalendarStatus.connected,
        importedEvents: events,
      ),);
    } catch (e) {
      emit(state.copyWith(
        status: GoogleCalendarStatus.error,
        error: e.toString(),
      ),);
    }
  }

  Future<void> syncEventToGoogle(AgendaEvent event) async {
    if (!state.isConnected) return;
    try {
      await _repo.syncToGoogle(event);
    } catch (e) {
      emit(state.copyWith(
        status: GoogleCalendarStatus.error,
        error: e.toString(),
      ),);
    }
  }
}
