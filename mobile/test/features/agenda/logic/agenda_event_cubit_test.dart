import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/agenda/data/models/agenda_event.dart';
import 'package:harmony/features/agenda/data/repositories/i_agenda_event_repository.dart';
import 'package:harmony/features/agenda/logic/agenda_event_cubit.dart';

// ─── Stub repo ────────────────────────────────────────────────────────────────

class _StubRepo implements IAgendaEventRepository {
  final List<AgendaEvent> _events = [];

  @override
  Future<List<AgendaEvent>> getEventsInRange(DateTime from, DateTime to) async =>
      _events
          .where(
            (e) => !e.startDate.isBefore(from) && !e.startDate.isAfter(to),
          )
          .toList();

  @override
  Future<List<AgendaEvent>> getUpcomingEvents({int limit = 5}) async =>
      _events.take(limit).toList();

  @override
  Future<List<AgendaEvent>> getImportantEventsNow() async =>
      _events.where((e) => e.important).toList();

  @override
  Future<List<AgendaEvent>> searchEvents(String query) async =>
      _events.where((e) => e.title.contains(query)).toList();

  @override
  Future<void> add(AgendaEvent event) async => _events.add(event);

  @override
  Future<void> update(AgendaEvent event) async {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx >= 0) _events[idx] = event;
  }

  @override
  Future<void> delete(String id) async => _events.removeWhere((e) => e.id == id);

  @override
  Future<AgendaEvent?> getById(String id) async =>
      _events.where((e) => e.id == id).cast<AgendaEvent?>().firstOrNull;
}

AgendaEvent _event({
  String id = 'e-001',
  String title = 'Test',
  EventCategory category = EventCategory.other,
  bool important = false,
}) =>
    AgendaEvent(
      id: id,
      title: title,
      category: category,
      startDate: DateTime(2026, 6, 1, 10),
      endDate: DateTime(2026, 6, 1, 11),
      color: const Color(0xFF64748B),
      important: important,
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late _StubRepo repo;
  late AgendaEventCubit cubit;

  setUp(() {
    repo = _StubRepo();
    cubit = AgendaEventCubit(repository: repo);
  });

  tearDown(() => cubit.close());

  group('AgendaEventCubit', () {
    test('initial state is loaded empty', () {
      expect(cubit.state.status, AgendaEventStatus.loaded);
      expect(cubit.state.events, isEmpty);
    });

    test('loadEventsForMonth emits loaded state', () async {
      repo._events.add(_event());
      await cubit.loadEventsForMonth(DateTime(2026, 6));
      expect(cubit.state.status, AgendaEventStatus.loaded);
      expect(cubit.state.events, hasLength(1));
    });

    test('addEvent persists and reloads', () async {
      await cubit.loadEventsForMonth(DateTime(2026, 6));
      await cubit.addEvent(_event());
      expect(cubit.state.events, hasLength(1));
    });

    test('deleteEvent removes from state', () async {
      final e = _event();
      repo._events.add(e);
      await cubit.loadEventsForMonth(DateTime(2026, 6));
      expect(cubit.state.events, hasLength(1));
      await cubit.deleteEvent(e.id);
      expect(cubit.state.events, isEmpty);
    });

    test('updateEvent updates existing event', () async {
      final e = _event();
      repo._events.add(e);
      await cubit.loadEventsForMonth(DateTime(2026, 6));
      await cubit.updateEvent(e.copyWith(title: 'Updated'));
      expect(cubit.state.events.first.title, 'Updated');
    });

    test('markImportant toggles important flag', () async {
      final e = _event();
      repo._events.add(e);
      await cubit.loadEventsForMonth(DateTime(2026, 6));
      await cubit.markImportant(e, important: true);
      expect(cubit.state.events.first.important, isTrue);
    });

    test('eventsForDay filters by date', () async {
      repo._events.add(_event());
      await cubit.loadEventsForMonth(DateTime(2026, 6));
      final today = cubit.state.eventsForDay(DateTime(2026, 6, 1));
      final other = cubit.state.eventsForDay(DateTime(2026, 6, 2));
      expect(today, hasLength(1));
      expect(other, isEmpty);
    });

    test('load error emits error status', () async {
      final failRepo = _FailingRepo();
      final failCubit = AgendaEventCubit(repository: failRepo);
      await failCubit.loadEventsForMonth(DateTime(2026, 6));
      expect(failCubit.state.status, AgendaEventStatus.error);
      expect(failCubit.state.error, isNotNull);
      await failCubit.close();
    });
  });
}

class _FailingRepo implements IAgendaEventRepository {
  @override
  Future<List<AgendaEvent>> getEventsInRange(DateTime from, DateTime to) =>
      Future.error('db error');
  @override
  Future<List<AgendaEvent>> getUpcomingEvents({int limit = 5}) async => [];
  @override
  Future<List<AgendaEvent>> getImportantEventsNow() async => [];
  @override
  Future<List<AgendaEvent>> searchEvents(String query) async => [];
  @override
  Future<void> add(AgendaEvent event) async {}
  @override
  Future<void> update(AgendaEvent event) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<AgendaEvent?> getById(String id) async => null;
}
