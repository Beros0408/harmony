import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/fitness/data/models/daily_steps.dart';

void main() {
  final today = DateTime(2026, 5, 27);

  group('DailySteps — calculs dérivés', () {
    test('progressRatio est 0 si goalSteps=0', () {
      final d = DailySteps(date: today, stepCount: 5000, goalSteps: 0);
      expect(d.progressRatio, 0.0);
    });

    test('progressRatio correct', () {
      final d = DailySteps(date: today, stepCount: 4000, goalSteps: 8000);
      expect(d.progressRatio, 0.5);
    });

    test('goalReached est faux en dessous de l\'objectif', () {
      final d = DailySteps(date: today, stepCount: 7999, goalSteps: 8000);
      expect(d.goalReached, isFalse);
    });

    test('goalReached est vrai à l\'objectif atteint', () {
      final d = DailySteps(date: today, stepCount: 8000, goalSteps: 8000);
      expect(d.goalReached, isTrue);
    });

    test('caloriesEstimated est stepCount * 0.04', () {
      final d = DailySteps(date: today, stepCount: 10000);
      expect(d.caloriesEstimated, closeTo(400.0, 0.01));
    });

    test('distanceMeters est stepCount * 0.762', () {
      final d = DailySteps(date: today, stepCount: 1000);
      expect(d.distanceMeters, closeTo(762.0, 0.01));
    });

    test('distanceKm = distanceMeters / 1000', () {
      final d = DailySteps(date: today, stepCount: 1000);
      expect(d.distanceKm, closeTo(0.762, 0.001));
    });

    test('activeMinutesEstimated est stepCount ~/ 100', () {
      final d = DailySteps(date: today, stepCount: 6247);
      expect(d.activeMinutesEstimated, 62);
    });
  });

  group('DailySteps — sérialisation toMap/fromMap', () {
    test('round-trip toMap → fromMap', () {
      final original = DailySteps(date: today, stepCount: 6500, goalSteps: 8000);
      final restored = DailySteps.fromMap(original.toMap());
      expect(restored, equals(original));
    });

    test('copyWith remplace correctement', () {
      final d = DailySteps(date: today, stepCount: 3000, goalSteps: 8000);
      final d2 = d.copyWith(stepCount: 5000);
      expect(d2.stepCount, 5000);
      expect(d2.goalSteps, 8000);
    });
  });
}
