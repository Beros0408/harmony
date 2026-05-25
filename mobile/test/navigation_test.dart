import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/core/router/route_names.dart';
import 'package:harmony/features/agenda/presentation/screens/agenda_screen.dart';
import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';
import 'package:harmony/features/call_filter/data/repositories/i_blacklist_repository.dart';
import 'package:harmony/features/call_filter/logic/blacklist_cubit.dart';
import 'package:harmony/features/call_filter/presentation/screens/call_filter_screen.dart';
import 'package:harmony/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:harmony/features/fitness/presentation/screens/fitness_screen.dart';
import 'package:harmony/features/parental/data/models/child_profile.dart';
import 'package:harmony/features/parental/data/models/safe_zone.dart';
import 'package:harmony/features/parental/data/repositories/i_child_profile_repository.dart';
import 'package:harmony/features/parental/data/repositories/i_location_repository.dart';
import 'package:harmony/features/parental/data/repositories/i_safe_zone_repository.dart';
import 'package:harmony/features/parental/data/repositories/i_sos_alert_repository.dart';
import 'package:harmony/features/parental/data/models/location_point.dart';
import 'package:harmony/features/parental/data/models/sos_alert.dart';
import 'package:harmony/features/parental/data/services/i_location_service.dart';
import 'package:harmony/features/parental/logic/child_profile_cubit.dart';
import 'package:harmony/features/parental/logic/location_cubit.dart';
import 'package:harmony/features/parental/logic/safe_zone_cubit.dart';
import 'package:harmony/features/parental/logic/sos_cubit.dart';
import 'package:harmony/features/parental/presentation/screens/parental_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

// ─── Stubs minimalistes ──────────────────────────────────────────────────────

class _EmptyBlacklistRepo implements IBlacklistRepository {
  @override Future<List<BlacklistEntry>> getAll() async => [];
  @override Future<BlacklistEntry?> getById(String id) async => null;
  @override Future<BlacklistEntry?> getByNumber(String phoneNumber) async => null;
  @override Future<void> add(BlacklistEntry entry) async {}
  @override Future<void> update(BlacklistEntry entry) async {}
  @override Future<void> delete(String id) async {}
  @override Future<void> clear() async {}
  @override Future<List<BlacklistEntry>> search(String query) async => [];
  @override Future<void> syncToNative() async {}
}

class _EmptyChildRepo implements IChildProfileRepository {
  @override Future<List<ChildProfile>> getAll() async => [];
  @override Future<ChildProfile?> getById(String id) async => null;
  @override Future<void> add(ChildProfile profile) async {}
  @override Future<void> update(ChildProfile profile) async {}
  @override Future<void> delete(String id) async {}
  @override Future<void> seed(List<ChildProfile> profiles) async {}
}

class _EmptySafeZoneRepo implements ISafeZoneRepository {
  @override Future<List<SafeZone>> getAll() async => [];
  @override Future<SafeZone?> getById(String id) async => null;
  @override Future<List<SafeZone>> getActiveZonesFor(String childId, DateTime at) async => [];
  @override Future<void> add(SafeZone zone) async {}
  @override Future<void> update(SafeZone zone) async {}
  @override Future<void> delete(String id) async {}
  @override Future<void> seed(List<SafeZone> zones) async {}
}

class _EmptyLocationRepo implements ILocationRepository {
  @override Future<void> addPoint(LocationPoint point) async {}
  @override Future<LocationPoint?> getLatest(String childId) async => null;
  @override Future<List<LocationPoint>> getHistory(String childId, DateTime from, DateTime to) async => [];
  @override Future<void> cleanupOlderThan(DateTime cutoff) async {}
}

class _EmptyLocationService implements ILocationService {
  @override Future<void> startTracking({TrackingMode mode = TrackingMode.standard}) async {}
  @override Future<void> stopTracking() async {}
  @override Future<LocationPoint?> getCurrentPosition(String childId) async => null;
  @override Stream<LocationPoint> positionStream(String childId) => const Stream.empty();
  @override Future<LocationPermissionStatus> requestPermissions() async => LocationPermissionStatus.denied;
  @override Future<LocationPermissionStatus> checkPermissions() async => LocationPermissionStatus.denied;
}

class _EmptySosRepo implements ISosAlertRepository {
  @override Future<void> trigger(SosAlert alert) async {}
  @override Future<List<SosAlert>> getActive() async => [];
  @override Future<List<SosAlert>> getAll() async => [];
  @override Future<void> acknowledge(String alertId) async {}
  @override Future<void> resolve(String alertId) async {}
}

// ─── Routeur de test ─────────────────────────────────────────────────────────

GoRouter _testRouter() => GoRouter(
      initialLocation: RouteNames.dashboard,
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.security,
          builder: (_, __) => const CallFilterScreen(),
        ),
        GoRoute(
          path: RouteNames.family,
          builder: (_, __) => const ParentalScreen(),
        ),
        GoRoute(
          path: RouteNames.fitness,
          builder: (_, __) => const FitnessScreen(),
        ),
        GoRoute(
          path: RouteNames.agenda,
          builder: (_, __) => const AgendaScreen(),
        ),
      ],
    );

Widget _buildTestApp() => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => BlacklistCubit(_EmptyBlacklistRepo())),
        BlocProvider(create: (_) => ChildProfileCubit(_EmptyChildRepo())),
        BlocProvider(create: (_) => SafeZoneCubit(_EmptySafeZoneRepo())),
        BlocProvider(create: (_) => LocationCubit(_EmptyLocationService(), _EmptyLocationRepo())),
        BlocProvider(
          create: (_) => SosCubit(_EmptySosRepo(), _EmptyLocationRepo(), _EmptyLocationService()),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.darkTheme,
        routerConfig: _testRouter(),
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('fr')],
      ),
    );

// Avance passé l'animation de navigation (par défaut 300ms + marge)
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

// Défile jusqu'à rendre le widget visible dans le ListView du dashboard
Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.dragUntilVisible(
    finder,
    find.byType(ListView),
    const Offset(0, -100),
  );
  await tester.pump();
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  group('Navigation Dashboard ->', () {
    testWidgets('tap Sécurité navigue vers CallFilterScreen', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Sécurité'));
      await _settle(tester);

      expect(find.byType(CallFilterScreen), findsOneWidget);
      expect(find.text('Sécurité & Filtrage'), findsOneWidget);
    });

    testWidgets('tap Famille navigue vers ParentalScreen', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Famille'));
      await _settle(tester);

      expect(find.byType(ParentalScreen), findsOneWidget);
      expect(find.text('Famille & Contrôle parental'), findsOneWidget);
    });

    testWidgets('tap Fitness navigue vers FitnessScreen', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      // Fitness peut être sous le fold — défile d'abord
      await _scrollTo(tester, find.text('Fitness'));

      await tester.tap(find.text('Fitness'));
      await _settle(tester);

      expect(find.byType(FitnessScreen), findsOneWidget);
      expect(find.text('Fitness & Performance'), findsOneWidget);
    });

    testWidgets('tap Agenda navigue vers AgendaScreen', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await _scrollTo(tester, find.text('Agenda'));

      await tester.tap(find.text('Agenda'));
      await _settle(tester);

      expect(find.byType(AgendaScreen), findsOneWidget);
      expect(find.text('Agenda & Planification'), findsOneWidget);
    });

    testWidgets('bouton retour depuis CallFilterScreen ramène au Dashboard', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Sécurité'));
      await _settle(tester);
      expect(find.byType(CallFilterScreen), findsOneWidget);

      // Appuie sur la flèche retour de HarmonyAppBar
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await _settle(tester);

      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}
