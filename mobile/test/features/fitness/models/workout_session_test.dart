import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/fitness/data/models/workout_session.dart';

void main() {
  final start = DateTime(2026, 5, 27, 8, 0);
  final end = DateTime(2026, 5, 27, 8, 30);

  group('WorkoutSession — propriétés', () {
    test('isActive est vrai sans endTime', () {
      final s = WorkoutSession(id: '1', type: WorkoutType.walking, startTime: start);
      expect(s.isActive, isTrue);
    });

    test('isActive est faux avec endTime', () {
      final s = WorkoutSession(
          id: '1', type: WorkoutType.running, startTime: start, endTime: end);
      expect(s.isActive, isFalse);
    });

    test('duration retourne la différence correcte', () {
      final s = WorkoutSession(
          id: '1', type: WorkoutType.cycling, startTime: start, endTime: end);
      expect(s.duration.inMinutes, 30);
    });

    test('distanceKm = distanceMeters / 1000', () {
      final s = WorkoutSession(
          id: '1', type: WorkoutType.running, startTime: start, distanceMeters: 5000);
      expect(s.distanceKm, 5.0);
    });
  });

  group('WorkoutSession — sérialisation', () {
    test('round-trip toMap → fromMap', () {
      final original = WorkoutSession(
        id: 'abc',
        type: WorkoutType.running,
        startTime: start,
        endTime: end,
        stepsTotal: 3200,
        distanceMeters: 2400.0,
      );
      final restored = WorkoutSession.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.type, original.type);
      expect(restored.stepsTotal, original.stepsTotal);
    });
  });

  group('WorkoutTypeX — displayName', () {
    test('walking → Marche', () => expect(WorkoutType.walking.displayName, 'Marche'));
    test('running → Course', () => expect(WorkoutType.running.displayName, 'Course'));
    test('cycling → Vélo', () => expect(WorkoutType.cycling.displayName, 'Vélo'));
  });
}
