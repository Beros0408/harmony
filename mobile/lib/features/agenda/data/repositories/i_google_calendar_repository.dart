import '../models/agenda_event.dart';
import '../models/google_calendar_sync.dart';

abstract interface class IGoogleCalendarRepository {
  Future<bool> isSignedIn();
  Future<GoogleCalendarSync?> getCurrentAccount();
  Future<void> signIn();
  Future<void> signOut();
  Future<List<AgendaEvent>> syncFromGoogle();
  Future<void> syncToGoogle(AgendaEvent event);
}
