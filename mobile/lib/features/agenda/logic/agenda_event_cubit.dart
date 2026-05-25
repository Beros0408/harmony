import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/agenda_event.dart';
import '../data/repositories/agenda_event_repository.dart';
import '../data/repositories/i_agenda_event_repository.dart';
import '../../../core/services/notification_service.dart';

// ─── State ───────────────────────────────────────────────────────────────────

enum AgendaEventStatus { loading, loaded, error }

class AgendaEventState extends Equatable {
  const AgendaEventState({
    this.status = AgendaEventStatus.loaded,
    this.events = const [],
    this.focusedMonth,
    this.error,
  });

  final AgendaEventStatus status;
  final List<AgendaEvent> events;
  final DateTime? focusedMonth;
  final String? error;

  AgendaEventState copyWith({
    AgendaEventStatus? status,
    List<AgendaEvent>? events,
    DateTime? focusedMonth,
    String? error,
    bool clearError = false,
  }) =>
      AgendaEventState(
        status: status ?? this.status,
        events: events ?? this.events,
        focusedMonth: focusedMonth ?? this.focusedMonth,
        error: clearError ? null : (error ?? this.error),
      );

  /// Événements pour un jour donné (comparaison date locale).
  List<AgendaEvent> eventsForDay(DateTime day) => events.where((e) {
        final s = e.startDate;
        return s.year == day.year && s.month == day.month && s.day == day.day;
      }).toList();

  @override
  List<Object?> get props => [status, events, focusedMonth, error];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class AgendaEventCubit extends Cubit<AgendaEventState> {
  AgendaEventCubit({
    IAgendaEventRepository? repository,
    NotificationService? notificationService,
  })  : _repo = repository ?? AgendaEventRepository.instance,
        _notifications = notificationService ?? NotificationService.instance,
        super(const AgendaEventState());

  final IAgendaEventRepository _repo;
  final NotificationService _notifications;

  Future<void> loadEventsForMonth(DateTime month) async {
    emit(state.copyWith(
      status: AgendaEventStatus.loading,
      focusedMonth: month,
      clearError: true,
    ),);
    try {
      final from = DateTime(month.year, month.month, 1);
      final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      final events = await _repo.getEventsInRange(from, to);
      emit(state.copyWith(status: AgendaEventStatus.loaded, events: events));
    } catch (e) {
      emit(state.copyWith(
        status: AgendaEventStatus.error,
        error: e.toString(),
      ),);
    }
  }

  Future<void> addEvent(AgendaEvent event) async {
    try {
      await _repo.add(event);
      await _refreshCurrentMonth();
      // Notifications non-bloquantes — silencées si plugin non initialisé (tests)
      try { await _notifications.scheduleReminder(event); } catch (_) {}
    } catch (e) {
      emit(state.copyWith(
        status: AgendaEventStatus.error,
        error: e.toString(),
      ),);
    }
  }

  Future<void> updateEvent(AgendaEvent event) async {
    try {
      await _repo.update(event);
      await _refreshCurrentMonth();
      try {
        await _notifications.cancelReminder(event.id);
        await _notifications.scheduleReminder(event);
      } catch (_) {}
    } catch (e) {
      emit(state.copyWith(
        status: AgendaEventStatus.error,
        error: e.toString(),
      ),);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repo.delete(id);
      await _refreshCurrentMonth();
      try { await _notifications.cancelReminder(id); } catch (_) {}
    } catch (e) {
      emit(state.copyWith(
        status: AgendaEventStatus.error,
        error: e.toString(),
      ),);
    }
  }

  Future<void> markImportant(AgendaEvent event, {required bool important}) async {
    await updateEvent(event.copyWith(important: important));
  }

  Future<void> _refreshCurrentMonth() async {
    final month = state.focusedMonth ?? DateTime.now();
    await loadEventsForMonth(month);
  }
}
