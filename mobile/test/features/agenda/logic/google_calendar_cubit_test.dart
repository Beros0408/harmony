import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/agenda/data/models/agenda_event.dart';
import 'package:harmony/features/agenda/data/models/google_calendar_sync.dart';
import 'package:harmony/features/agenda/data/repositories/i_google_calendar_repository.dart';
import 'package:harmony/features/agenda/logic/google_calendar_cubit.dart';

// ─── Stub repos ───────────────────────────────────────────────────────────────

class _DisconnectedRepo implements IGoogleCalendarRepository {
  @override Future<bool> isSignedIn() async => false;
  @override Future<GoogleCalendarSync?> getCurrentAccount() async => null;
  @override Future<void> signIn() async {}
  @override Future<void> signOut() async {}
  @override Future<List<AgendaEvent>> syncFromGoogle() async => [];
  @override Future<void> syncToGoogle(AgendaEvent event) async {}
}

class _ConnectedRepo implements IGoogleCalendarRepository {
  @override Future<bool> isSignedIn() async => true;
  @override Future<GoogleCalendarSync?> getCurrentAccount() async =>
      const GoogleCalendarSync(
        id: 'sync-001',
        accountEmail: 'test@gmail.com',
        lastSyncAt: null,
      );
  @override Future<void> signIn() async {}
  @override Future<void> signOut() async {}
  @override Future<List<AgendaEvent>> syncFromGoogle() async => [];
  @override Future<void> syncToGoogle(AgendaEvent event) async {}
}

class _SignInRepo implements IGoogleCalendarRepository {
  bool _signedIn = false;
  @override Future<bool> isSignedIn() async => _signedIn;
  @override Future<GoogleCalendarSync?> getCurrentAccount() async =>
      _signedIn
          ? const GoogleCalendarSync(id: 'sync-002', accountEmail: 'user@gmail.com')
          : null;
  @override Future<void> signIn() async => _signedIn = true;
  @override Future<void> signOut() async => _signedIn = false;
  @override Future<List<AgendaEvent>> syncFromGoogle() async => [];
  @override Future<void> syncToGoogle(AgendaEvent event) async {}
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('GoogleCalendarCubit', () {
    test('initial state is disconnected', () {
      final cubit = GoogleCalendarCubit(repository: _DisconnectedRepo());
      expect(cubit.state.status, GoogleCalendarStatus.disconnected);
      expect(cubit.state.account, isNull);
      cubit.close();
    });

    test('checkConnection when not signed in stays disconnected', () async {
      final cubit = GoogleCalendarCubit(repository: _DisconnectedRepo());
      await cubit.checkConnection();
      expect(cubit.state.status, GoogleCalendarStatus.disconnected);
      cubit.close();
    });

    test('checkConnection when signed in emits connected', () async {
      final cubit = GoogleCalendarCubit(repository: _ConnectedRepo());
      await cubit.checkConnection();
      expect(cubit.state.status, GoogleCalendarStatus.connected);
      expect(cubit.state.account?.accountEmail, 'test@gmail.com');
      cubit.close();
    });

    test('signIn transitions to connected', () async {
      final repo = _SignInRepo();
      final cubit = GoogleCalendarCubit(repository: repo);
      await cubit.signIn();
      expect(cubit.state.status, GoogleCalendarStatus.connected);
      expect(cubit.state.account, isNotNull);
      cubit.close();
    });

    test('signOut resets to disconnected', () async {
      final repo = _SignInRepo();
      final cubit = GoogleCalendarCubit(repository: repo);
      await cubit.signIn();
      await cubit.signOut();
      expect(cubit.state.status, GoogleCalendarStatus.disconnected);
      expect(cubit.state.account, isNull);
      cubit.close();
    });

    test('isConnected is true when connected or syncing', () {
      const connected = GoogleCalendarState(
        status: GoogleCalendarStatus.connected,
      );
      const syncing = GoogleCalendarState(
        status: GoogleCalendarStatus.syncing,
      );
      const disconnected = GoogleCalendarState(
        status: GoogleCalendarStatus.disconnected,
      );
      expect(connected.isConnected, isTrue);
      expect(syncing.isConnected, isTrue);
      expect(disconnected.isConnected, isFalse);
    });

    test('syncFromGoogle when not connected does nothing', () async {
      final cubit = GoogleCalendarCubit(repository: _DisconnectedRepo());
      await cubit.syncFromGoogle();
      expect(cubit.state.status, GoogleCalendarStatus.disconnected);
      cubit.close();
    });
  });
}
