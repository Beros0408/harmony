import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/models/location_point.dart';
import 'package:harmony/features/parental/data/models/sos_alert.dart';
import 'package:harmony/features/parental/data/repositories/i_location_repository.dart';
import 'package:harmony/features/parental/data/repositories/i_sos_alert_repository.dart';
import 'package:harmony/features/parental/data/services/i_location_service.dart';
import 'package:harmony/features/parental/logic/sos_cubit.dart';

// ─── Stubs ───────────────────────────────────────────────────────────────────

class _StubSosRepo implements ISosAlertRepository {
  final List<SosAlert> triggered = [];
  final List<String> resolved = [];

  @override Future<void> trigger(SosAlert alert) async => triggered.add(alert);
  @override Future<List<SosAlert>> getActive() async => triggered.where((a) => a.status == SosStatus.active).toList();
  @override Future<List<SosAlert>> getAll() async => triggered;
  @override Future<void> acknowledge(String alertId) async {}
  @override Future<void> resolve(String alertId) async => resolved.add(alertId);
}

class _StubLocationRepo implements ILocationRepository {
  @override Future<void> addPoint(LocationPoint point) async {}
  @override Future<LocationPoint?> getLatest(String childId) async => null;
  @override Future<List<LocationPoint>> getHistory(String childId, DateTime from, DateTime to) async => [];
  @override Future<void> cleanupOlderThan(DateTime cutoff) async {}
}

class _StubLocationService implements ILocationService {
  @override Future<void> startTracking({TrackingMode mode = TrackingMode.standard}) async {}
  @override Future<void> stopTracking() async {}
  @override Future<LocationPoint?> getCurrentPosition(String childId) async => null;
  @override Stream<LocationPoint> positionStream(String childId) => const Stream.empty();
  @override Future<LocationPermissionStatus> requestPermissions() async => LocationPermissionStatus.granted;
  @override Future<LocationPermissionStatus> checkPermissions() async => LocationPermissionStatus.granted;
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('SosCubit', () {
    late _StubSosRepo sosRepo;
    late _StubLocationRepo locationRepo;
    late _StubLocationService locationService;

    setUp(() {
      sosRepo = _StubSosRepo();
      locationRepo = _StubLocationRepo();
      locationService = _StubLocationService();
    });

    SosCubit buildCubit() => SosCubit(sosRepo, locationRepo, locationService);

    test('état initial est SosIdle', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<SosIdle>());
      cubit.close();
    });

    blocTest<SosCubit, SosState>(
      'trigger() passe à SosActive et enregistre l\'alerte',
      build: buildCubit,
      act: (cubit) => cubit.trigger(childName: 'Lucas', childId: 'child-001'),
      expect: () => [isA<SosActive>()],
      verify: (cubit) {
        expect(sosRepo.triggered, hasLength(1));
        expect(sosRepo.triggered.first.childName, 'Lucas');
      },
    );

    blocTest<SosCubit, SosState>(
      'cancel() depuis SosActive remet en SosIdle via SosResolved',
      build: buildCubit,
      act: (cubit) async {
        await cubit.trigger(childName: 'Emma', childId: 'child-002');
        final active = cubit.state as SosActive;
        await cubit.cancel(active.alert.id);
        // Attendre la transition SosResolved → SosIdle (1 seconde)
        await Future<void>.delayed(const Duration(milliseconds: 1100));
      },
      expect: () => [
        isA<SosActive>(),
        isA<SosResolved>(),
        isA<SosIdle>(),
      ],
      verify: (cubit) {
        expect(sosRepo.resolved, hasLength(1));
      },
    );

    test('callDelay est de 2 minutes', () {
      final cubit = buildCubit();
      expect(cubit.callDelay, const Duration(minutes: 2));
      cubit.close();
    });

    blocTest<SosCubit, SosState>(
      'SosActive contient le nom de l\'enfant',
      build: buildCubit,
      act: (cubit) => cubit.trigger(childName: 'Lucas'),
      expect: () => [
        predicate<SosState>(
          (s) => s is SosActive && s.alert.childName == 'Lucas',
          'SosActive avec childName Lucas',
        ),
      ],
    );
  });
}
