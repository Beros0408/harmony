import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/agenda/data/models/task_item.dart';

void main() {
  group('TaskItem', () {
    const task = TaskItem(
      id: 't-001',
      title: 'Préparer la réunion',
      urgency: TaskUrgency.high,
      importance: TaskImportance.high,
    );

    test('urgent + important → doFirst', () {
      expect(task.quadrant, EisenhowerQuadrant.doFirst);
    });

    test('not urgent + important → schedule', () {
      const t = TaskItem(
        id: 't-002',
        title: 'Lire le rapport',
        urgency: TaskUrgency.low,
        importance: TaskImportance.high,
      );
      expect(t.quadrant, EisenhowerQuadrant.schedule);
    });

    test('urgent + not important → delegate', () {
      const t = TaskItem(
        id: 't-003',
        title: 'Répondre email',
        urgency: TaskUrgency.high,
        importance: TaskImportance.low,
      );
      expect(t.quadrant, EisenhowerQuadrant.delegate);
    });

    test('not urgent + not important → delete', () {
      const t = TaskItem(
        id: 't-004',
        title: 'Lire flux RSS',
        urgency: TaskUrgency.low,
        importance: TaskImportance.low,
      );
      expect(t.quadrant, EisenhowerQuadrant.delete);
    });

    test('medium urgency is treated as urgent', () {
      const t = TaskItem(
        id: 't-005',
        title: 'Réunion équipe',
        urgency: TaskUrgency.medium,
        importance: TaskImportance.medium,
      );
      expect(t.quadrant, EisenhowerQuadrant.doFirst);
    });

    test('toMap / fromMap round-trip', () {
      final map = task.toMap();
      final restored = TaskItem.fromMap(map);
      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.urgency, task.urgency);
      expect(restored.importance, task.importance);
      expect(restored.completed, false);
    });

    test('completed stored as int', () {
      final completed = task.copyWith(completed: true);
      expect(completed.toMap()['completed'], 1);
      expect(task.toMap()['completed'], 0);
    });

    test('deadline serialization', () {
      final deadline = DateTime(2026, 7, 1, 9);
      final withDeadline = task.copyWith(deadline: deadline);
      final map = withDeadline.toMap();
      final restored = TaskItem.fromMap(map);
      expect(restored.deadline, deadline);
    });

    test('null deadline round-trips correctly', () {
      final map = task.toMap();
      final restored = TaskItem.fromMap(map);
      expect(restored.deadline, isNull);
    });

    test('props equality on id', () {
      const other = TaskItem(
        id: 't-001',
        title: 'Autre titre',
        urgency: TaskUrgency.low,
        importance: TaskImportance.low,
      );
      expect(task, equals(other));
    });
  });
}
