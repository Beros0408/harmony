import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/agenda/data/models/agenda_event.dart';

void main() {
  group('AgendaEvent', () {
    final start = DateTime(2026, 6, 1, 10);
    final end = DateTime(2026, 6, 1, 11);
    final event = AgendaEvent(
      id: 'abc-123',
      title: 'Test',
      category: EventCategory.professional,
      startDate: start,
      endDate: end,
      color: const Color(0xFF3B82F6),
    );

    test('props equality uses id only', () {
      final other = AgendaEvent(
        id: 'abc-123',
        title: 'Different Title',
        category: EventCategory.sport,
        startDate: start,
        endDate: end,
        color: const Color(0xFF10B981),
      );
      expect(event, equals(other));
    });

    test('different ids are not equal', () {
      final other = event.copyWith();
      final newEvent = AgendaEvent(
        id: 'xyz-999',
        title: event.title,
        category: event.category,
        startDate: event.startDate,
        endDate: event.endDate,
        color: event.color,
      );
      expect(other, equals(event));
      expect(newEvent, isNot(equals(event)));
    });

    test('toMap / fromMap round-trip', () {
      final map = event.toMap();
      final restored = AgendaEvent.fromMap(map);
      expect(restored.id, event.id);
      expect(restored.title, event.title);
      expect(restored.category, event.category);
      expect(restored.startDate, event.startDate);
      expect(restored.endDate, event.endDate);
      expect(restored.important, false);
      expect(restored.color.toARGB32(), event.color.toARGB32());
    });

    test('toMap stores important as int', () {
      final importantEvent = event.copyWith(important: true);
      expect(importantEvent.toMap()['important'], 1);
      expect(event.toMap()['important'], 0);
    });

    test('familyMemberIds serialization', () {
      final withMembers = event.copyWith(familyMemberIds: ['a', 'b', 'c']);
      final map = withMembers.toMap();
      final restored = AgendaEvent.fromMap(map);
      expect(restored.familyMemberIds, ['a', 'b', 'c']);
    });

    test('empty familyMemberIds round-trips cleanly', () {
      final map = event.toMap();
      final restored = AgendaEvent.fromMap(map);
      expect(restored.familyMemberIds, isEmpty);
    });

    test('copyWith preserves unset fields', () {
      final updated = event.copyWith(title: 'New Title');
      expect(updated.id, event.id);
      expect(updated.title, 'New Title');
      expect(updated.category, event.category);
    });

    test('default reminderMinutesBefore is 30', () {
      expect(event.reminderMinutesBefore, 30);
    });

    test('categoryColor returns distinct colors', () {
      final colors = EventCategory.values.map(categoryColor).toSet();
      expect(colors.length, EventCategory.values.length);
    });
  });
}
