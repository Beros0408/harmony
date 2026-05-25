import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum CalendarViewMode { month, week, day }

// ─── State ───────────────────────────────────────────────────────────────────

class CalendarViewState extends Equatable {
  const CalendarViewState({
    this.mode = CalendarViewMode.month,
    required this.focusedDay,
    required this.selectedDay,
  });

  final CalendarViewMode mode;
  final DateTime focusedDay;
  final DateTime selectedDay;

  CalendarViewState copyWith({
    CalendarViewMode? mode,
    DateTime? focusedDay,
    DateTime? selectedDay,
  }) =>
      CalendarViewState(
        mode: mode ?? this.mode,
        focusedDay: focusedDay ?? this.focusedDay,
        selectedDay: selectedDay ?? this.selectedDay,
      );

  @override
  List<Object?> get props => [mode, focusedDay, selectedDay];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class CalendarViewCubit extends Cubit<CalendarViewState> {
  CalendarViewCubit()
      : super(CalendarViewState(
          focusedDay: DateTime.now(),
          selectedDay: DateTime.now(),
        ),);

  void setMode(CalendarViewMode mode) {
    emit(state.copyWith(mode: mode));
  }

  void setFocusedDay(DateTime day) {
    emit(state.copyWith(focusedDay: day));
  }

  void selectDay(DateTime day) {
    emit(state.copyWith(selectedDay: day, focusedDay: day));
  }

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(focusedDay: now, selectedDay: now));
  }

  void goToPreviousMonth() {
    final current = state.focusedDay;
    final prev = DateTime(current.year, current.month - 1, 1);
    emit(state.copyWith(focusedDay: prev));
  }

  void goToNextMonth() {
    final current = state.focusedDay;
    final next = DateTime(current.year, current.month + 1, 1);
    emit(state.copyWith(focusedDay: next));
  }
}
