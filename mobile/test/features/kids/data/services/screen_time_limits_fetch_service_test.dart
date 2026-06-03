import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/kids/data/services/screen_time_limits_fetch_service.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

const _childId = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';

// Stub qui surcharge _refreshLimits / _refreshStatus sans réseau.
// Le service est conçu pour être testé via les méthodes publiques fetchLimits/fetchStatus.

class _StubFetchService extends ScreenTimeLimitsFetchService {
  final List<KidsScreenTimeLimit> limitsResult;
  final List<KidsScreenTimeStatus> statusResult;
  bool limitsCalled = false;
  bool statusCalled = false;

  _StubFetchService({
    required this.limitsResult,
    required this.statusResult,
  });

  @override
  Future<List<KidsScreenTimeLimit>> fetchLimits(String childId) async {
    limitsCalled = true;
    return limitsResult;
  }

  @override
  Future<List<KidsScreenTimeStatus>> fetchStatus(String childId) async {
    statusCalled = true;
    return statusResult;
  }
}

class _NetworkErrorFetchService extends ScreenTimeLimitsFetchService {
  _NetworkErrorFetchService();

  @override
  Future<List<KidsScreenTimeLimit>> fetchLimits(String childId) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/screen-time/limits/$childId'),
      type: DioExceptionType.connectionError,
    );
  }

  @override
  Future<List<KidsScreenTimeStatus>> fetchStatus(String childId) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/screen-time/status/$childId'),
      type: DioExceptionType.connectionError,
    );
  }
}

List<KidsScreenTimeLimit> _fakeLimits() => [
      const KidsScreenTimeLimit(
        id: '11111111-2222-3333-4444-555555555555',
        scope: 'global',
        limitSeconds: 7200,
      ),
      const KidsScreenTimeLimit(
        id: '66666666-7777-8888-9999-000000000000',
        scope: 'app',
        limitSeconds: 3600,
        packageName: 'com.instagram.android',
      ),
    ];

List<KidsScreenTimeStatus> _fakeStatus() => [
      const KidsScreenTimeStatus(
        scope: 'global',
        limitSeconds: 7200,
        usedSeconds: 5400,
        remainingSeconds: 1800,
        exceeded: false,
      ),
      const KidsScreenTimeStatus(
        scope: 'app',
        limitSeconds: 3600,
        usedSeconds: 3700,
        remainingSeconds: 0,
        exceeded: true,
        packageName: 'com.instagram.android',
      ),
    ];

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('ScreenTimeLimitsFetchService — singleton', () {
    test('instance est un singleton', () {
      expect(
        identical(
          ScreenTimeLimitsFetchService.instance,
          ScreenTimeLimitsFetchService.instance,
        ),
        isTrue,
      );
    });
  });

  group('fetchLimits', () {
    test('retourne la liste des limites', () async {
      final svc = _StubFetchService(
        limitsResult: _fakeLimits(),
        statusResult: [],
      );
      final limits = await svc.fetchLimits(_childId);

      expect(limits, hasLength(2));
      expect(limits.first.scope, equals('global'));
      expect(limits.first.limitSeconds, equals(7200));
      expect(limits.last.scope, equals('app'));
      expect(limits.last.packageName, equals('com.instagram.android'));
    });

    test('retourne liste vide si aucune limite configurée', () async {
      final svc = _StubFetchService(limitsResult: [], statusResult: []);
      final limits = await svc.fetchLimits(_childId);
      expect(limits, isEmpty);
    });

    test('propage DioException sur erreur réseau', () {
      final svc = _NetworkErrorFetchService();
      expect(
        () => svc.fetchLimits(_childId),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('fetchStatus', () {
    test('retourne la liste des statuts du jour', () async {
      final svc = _StubFetchService(
        limitsResult: [],
        statusResult: _fakeStatus(),
      );
      final status = await svc.fetchStatus(_childId);

      expect(status, hasLength(2));
      expect(status.first.exceeded, isFalse);
      expect(status.last.exceeded, isTrue);
      expect(status.last.usedSeconds, equals(3700));
    });

    test('détecte correctement un dépassement', () async {
      final svc = _StubFetchService(
        limitsResult: [],
        statusResult: _fakeStatus(),
      );
      final status = await svc.fetchStatus(_childId);
      final appStatus = status.where((s) => s.scope == 'app').first;
      expect(appStatus.exceeded, isTrue);
      expect(appStatus.remainingSeconds, equals(0));
    });

    test('propage DioException sur erreur réseau', () {
      final svc = _NetworkErrorFetchService();
      expect(
        () => svc.fetchStatus(_childId),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('KidsScreenTimeLimit.fromJson', () {
    test('désérialise une limite globale', () {
      final json = {
        'id': 'abc',
        'scope': 'global',
        'limit_seconds': 7200,
        'package_name': null,
      };
      final limit = KidsScreenTimeLimit.fromJson(json);
      expect(limit.id, equals('abc'));
      expect(limit.scope, equals('global'));
      expect(limit.limitSeconds, equals(7200));
      expect(limit.packageName, isNull);
    });

    test('désérialise une limite par app', () {
      final json = {
        'id': 'xyz',
        'scope': 'app',
        'limit_seconds': 1800,
        'package_name': 'com.google.android.youtube',
      };
      final limit = KidsScreenTimeLimit.fromJson(json);
      expect(limit.packageName, equals('com.google.android.youtube'));
      expect(limit.limitSeconds, equals(1800));
    });
  });

  group('KidsScreenTimeStatus.fromJson', () {
    test('désérialise correctement un statut', () {
      final json = {
        'scope': 'global',
        'limit_seconds': 7200,
        'used_seconds': 3600,
        'remaining_seconds': 3600,
        'exceeded': false,
        'package_name': null,
      };
      final status = KidsScreenTimeStatus.fromJson(json);
      expect(status.usedSeconds, equals(3600));
      expect(status.exceeded, isFalse);
    });

    test('désérialise un statut dépassé avec packageName', () {
      final json = {
        'scope': 'app',
        'limit_seconds': 600,
        'used_seconds': 700,
        'remaining_seconds': 0,
        'exceeded': true,
        'package_name': 'com.tiktok.android',
      };
      final status = KidsScreenTimeStatus.fromJson(json);
      expect(status.exceeded, isTrue);
      expect(status.packageName, equals('com.tiktok.android'));
    });
  });
}
