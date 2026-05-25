import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/models/child_profile.dart';
import 'package:harmony/features/parental/data/models/location_point.dart';
import 'package:harmony/features/parental/data/models/safe_zone.dart';
import 'package:harmony/features/parental/data/models/sos_alert.dart';
import 'package:harmony/features/parental/data/repositories/i_child_profile_repository.dart';
import 'package:harmony/features/parental/data/repositories/i_location_repository.dart';
import 'package:harmony/features/parental/data/repositories/i_safe_zone_repository.dart';
import 'package:harmony/features/parental/data/repositories/i_sos_alert_repository.dart';
import 'package:harmony/features/parental/data/services/i_location_service.dart';
import 'package:harmony/features/parental/logic/child_profile_cubit.dart';
import 'package:harmony/features/parental/logic/location_cubit.dart';
import 'package:harmony/features/parental/logic/safe_zone_cubit.dart';
import 'package:harmony/features/parental/logic/sos_cubit.dart';
import 'package:harmony/features/parental/presentation/screens/parental_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/core/router/route_names.dart';

// ─── Stubs ───────────────────────────────────────────────────────────────────

class _EmptyChildRepo implements IChildProfileRepository {
  @override Future<List<ChildProfile>> getAll() async => [];
  @override Future<ChildProfile?> getById(String id) async => null;
  @override Future<void> add(ChildProfile p) async {}
  @override Future<void> update(ChildProfile p) async {}
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

// ─── Helper ──────────────────────────────────────────────────────────────────

Widget _buildTestScreen() {
  final router = GoRouter(
    initialLocation: RouteNames.family,
    routes: [
      GoRoute(
        path: RouteNames.family,
        builder: (_, __) => const ParentalScreen(),
      ),
      GoRoute(
        path: RouteNames.safeZoneEditor,
        builder: (_, __) => const Scaffold(body: Text('Editor')),
      ),
    ],
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ChildProfileCubit(_EmptyChildRepo())),
      BlocProvider(create: (_) => SafeZoneCubit(_EmptySafeZoneRepo())),
      BlocProvider(create: (_) => LocationCubit(_EmptyLocationService(), _EmptyLocationRepo())),
      BlocProvider(
        create: (_) => SosCubit(_EmptySosRepo(), _EmptyLocationRepo(), _EmptyLocationService()),
      ),
    ],
    child: MaterialApp.router(
      theme: AppTheme.darkTheme,
      routerConfig: router,
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('fr')],
    ),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('ParentalScreen', () {
    testWidgets('affiche le titre "Famille & Contrôle parental"', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pump();
      expect(find.text('Famille & Contrôle parental'), findsOneWidget);
    });

    testWidgets('affiche la section enfants', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pump();
      // Section header "MES ENFANTS"
      expect(find.text('MES ENFANTS'), findsOneWidget);
    });

    testWidgets('affiche la section carte', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pump();
      expect(find.text('LOCALISATION EN TEMPS RÉEL'), findsOneWidget);
    });

    testWidgets('affiche la section zones', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pump();
      expect(find.text('ZONES AUTORISÉES'), findsOneWidget);
    });

    testWidgets('affiche le bouton SOS', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pump();
      expect(find.text('SOS'), findsWidgets);
    });

    testWidgets('affiche le FAB pour ajouter une zone', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pump();
      expect(find.text('Ajouter une zone'), findsOneWidget);
    });

    testWidgets('affiche la banner localisation requise quand permission refusée', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pump();
      // Location state starts as LocationPermissionRequired
      expect(find.text('Localisation requise'), findsOneWidget);
    });

    testWidgets('ParentalScreen est un StatefulWidget', (tester) async {
      await tester.pumpWidget(_buildTestScreen());
      await tester.pump();
      expect(find.byType(ParentalScreen), findsOneWidget);
    });
  });
}
