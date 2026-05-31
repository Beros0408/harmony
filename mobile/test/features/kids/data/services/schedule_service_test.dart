import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/kids/data/services/schedule_service.dart';

// Helpers pour créer des plages de test rapidement
LockSchedule _schedule({
  required int startH,
  required int startM,
  required int endH,
  required int endM,
  required List<int> days,
}) =>
    LockSchedule(
      id: 'test',
      label: 'test',
      startMinutes: startH * 60 + startM,
      endMinutes: endH * 60 + endM,
      daysOfWeek: days,
    );

// 2026-05-04 = lundi (weekday 1)
// 2026-05-05 = mardi (weekday 2)
// 2026-05-03 = dimanche (weekday 7)
DateTime _dt(int year, int month, int day, int hour, int minute) =>
    DateTime(year, month, day, hour, minute);

void main() {
  group('isInSchedule — plage normale (sans traversée de minuit)', () {
    final schedule = _schedule(startH: 9, startM: 0, endH: 17, endM: 0, days: [1]);

    test('lundi 10h → dans la plage', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 10, 0)), isTrue);
    });

    test('lundi 09h00 (exactement au début) → dans la plage', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 9, 0)), isTrue);
    });

    test('lundi 17h00 (exactement à la fin) → hors plage', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 17, 0)), isFalse);
    });

    test('lundi 18h → hors plage (après fin)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 18, 0)), isFalse);
    });

    test('lundi 08h → hors plage (avant début)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 8, 0)), isFalse);
    });

    test('mardi 10h → hors plage (mauvais jour)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 5, 10, 0)), isFalse);
    });
  });

  group('isInSchedule — plage traversant minuit (21:00 → 07:00)', () {
    final schedule = _schedule(startH: 21, startM: 0, endH: 7, endM: 0, days: [1]);

    test('lundi 22h → dans la plage (partie avant minuit)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 22, 0)), isTrue);
    });

    test('lundi 21h00 (exactement au début) → dans la plage', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 21, 0)), isTrue);
    });

    test('mardi 06h → dans la plage (partie après minuit, veille=lundi)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 5, 6, 0)), isTrue);
    });

    test('mardi 07h00 (exactement à la fin) → hors plage', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 5, 7, 0)), isFalse);
    });

    test('mardi 08h → hors plage (après fin)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 5, 8, 0)), isFalse);
    });

    test('lundi 20h → hors plage (avant début)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 20, 0)), isFalse);
    });

    test('lundi 22h mais jours=[2] → hors plage (lundi absent des jours)', () {
      final s = _schedule(startH: 21, startM: 0, endH: 7, endM: 0, days: [2]);
      expect(isInSchedule(s, now: _dt(2026, 5, 4, 22, 0)), isFalse);
    });

    test('mardi 06h mais veille dimanche et jours=[7] → hors plage', () {
      // mardi 06h, veille=lundi(1), mais jours=[7]=dimanche → false
      expect(isInSchedule(schedule, now: _dt(2026, 5, 5, 6, 0)), isTrue);
      final sNoMonday = _schedule(startH: 21, startM: 0, endH: 7, endM: 0, days: [2]);
      expect(isInSchedule(sNoMonday, now: _dt(2026, 5, 5, 6, 0)), isFalse);
    });
  });

  group('isInSchedule — traversée dimanche → lundi', () {
    // jours=[7]=dimanche, plage 22:00 → 06:00
    final schedule = _schedule(startH: 22, startM: 0, endH: 6, endM: 0, days: [7]);

    test('dimanche 23h → dans la plage (weekday 7)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 3, 23, 0)), isTrue);
    });

    test('lundi 05h → dans la plage (veille=dimanche=7)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 5, 0)), isTrue);
    });

    test('lundi 07h → hors plage (après fin)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 7, 0)), isFalse);
    });
  });

  group('isInSchedule — plage exactement à minuit (00:00)', () {
    // 23:00 → 00:30 : traverse minuit
    final schedule = _schedule(startH: 23, startM: 0, endH: 0, endM: 30, days: [1]);

    test('lundi 23h30 → dans la plage', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 4, 23, 30)), isTrue);
    });

    test('mardi 00h15 → dans la plage (après minuit, veille=lundi)', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 5, 0, 15)), isTrue);
    });

    test('mardi 00h30 → hors plage', () {
      expect(isInSchedule(schedule, now: _dt(2026, 5, 5, 0, 30)), isFalse);
    });
  });
}
