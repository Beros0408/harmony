import '../models/agenda_event.dart';

abstract interface class IAgendaEventRepository {
  Future<List<AgendaEvent>> getEventsInRange(DateTime from, DateTime to);
  Future<List<AgendaEvent>> getUpcomingEvents({int limit = 5});
  Future<List<AgendaEvent>> getImportantEventsNow();
  Future<List<AgendaEvent>> searchEvents(String query);
  Future<void> add(AgendaEvent event);
  Future<void> update(AgendaEvent event);
  Future<void> delete(String id);
  Future<AgendaEvent?> getById(String id);
}
