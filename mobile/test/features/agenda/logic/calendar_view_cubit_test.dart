import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/agenda/logic/calendar_view_cubit.dart';

void main() {
  group('CalendarViewCubit', () {
    late CalendarViewCubit cubit;

    setUp(() => cubit = CalendarViewCubit());
    tearDown(() => cubit.close());

    test('initial focusedDay is today', () {
      final now = DateTime.now();
      expect(cubit.state.focusedDay.year, now.year);
      expect(cubit.state.focusedDay.month, now.month);
      expect(cubit.state.focusedDay.day, now.day);
    });

    test('initial mode is month', () {
      expect(cubit.state.mode, CalendarViewMode.month);
    });

    test('setMode changes view mode', () {
      cubit.setMode(CalendarViewMode.week);
      expect(cubit.state.mode, CalendarViewMode.week);
    });

    test('selectDay updates both selectedDay and focusedDay', () {
      final day = DateTime(2026, 8, 15);
      cubit.selectDay(day);
      expect(cubit.state.selectedDay, day);
      expect(cubit.state.focusedDay, day);
    });

    test('setFocusedDay only changes focusedDay', () {
      final originalSelected = cubit.state.selectedDay;
      cubit.setFocusedDay(DateTime(2026, 9, 1));
      expect(cubit.state.focusedDay, DateTime(2026, 9, 1));
      expect(cubit.state.selectedDay, originalSelected);
    });

    test('goToToday resets to today', () {
      cubit.selectDay(DateTime(2025, 1, 1));
      cubit.goToToday();
      final now = DateTime.now();
      expect(cubit.state.focusedDay.day, now.day);
    });

    test('goToPreviousMonth decrements month', () {
      cubit.setFocusedDay(DateTime(2026, 6, 15));
      cubit.goToPreviousMonth();
      expect(cubit.state.focusedDay.month, 5);
      expect(cubit.state.focusedDay.year, 2026);
    });

    test('goToNextMonth increments month', () {
      cubit.setFocusedDay(DateTime(2026, 11, 1));
      cubit.goToNextMonth();
      expect(cubit.state.focusedDay.month, 12);
    });

    test('goToNextMonth wraps year', () {
      cubit.setFocusedDay(DateTime(2026, 12, 1));
      cubit.goToNextMonth();
      expect(cubit.state.focusedDay.month, 1);
      expect(cubit.state.focusedDay.year, 2027);
    });
  });
}
