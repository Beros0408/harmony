import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/services/screen_time_limits_service.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

const _childId = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
const _limitId = '11111111-2222-3333-4444-555555555555';

ScreenTimeLimit _fakeGlobalLimit() => const ScreenTimeLimit(
      id: _limitId,
      childId: _childId,
      scope: 'global',
      limitSeconds: 7200,
    );

ScreenTimeLimit _fakeAppLimit() => const ScreenTimeLimit(
      id: '66666666-7777-8888-9999-000000000000',
      childId: _childId,
      scope: 'app',
      limitSeconds: 3600,
      packageName: 'com.instagram.android',
      appLabel: 'Instagram',
    );

ScreenTimeStatusEntry _fakeStatusGlobal() => const ScreenTimeStatusEntry(
      scope: 'global',
      limitSeconds: 7200,
      usedSeconds: 5400,
      remainingSeconds: 1800,
      exceeded: false,
    );

ScreenTimeStatusEntry _fakeStatusApp() => const ScreenTimeStatusEntry(
      scope: 'app',
      limitSeconds: 3600,
      usedSeconds: 3700,
      remainingSeconds: 0,
      exceeded: true,
      packageName: 'com.instagram.android',
      appLabel: 'Instagram',
    );

// Stubs overriding the service methods

class _StubGetLimits extends ScreenTimeLimitsService {
  final List<ScreenTimeLimit> result;
  _StubGetLimits(this.result);

  @override
  Future<List<ScreenTimeLimit>> getLimits(String childId) async => result;
}

class _StubSetLimit extends ScreenTimeLimitsService {
  ScreenTimeLimit? lastResult;
  final ScreenTimeLimit Function(
    String childId,
    String scope,
    int limitSeconds,
    String? packageName,
  ) handler;

  _StubSetLimit(this.handler);

  @override
  Future<ScreenTimeLimit> setLimit({
    required String childId,
    required String scope,
    required int limitSeconds,
    String? packageName,
  }) async =>
      handler(childId, scope, limitSeconds, packageName);
}

class _StubDeleteLimit extends ScreenTimeLimitsService {
  String? deletedId;

  @override
  Future<void> deleteLimit(String limitId) async {
    deletedId = limitId;
  }
}

class _StubGetStatus extends ScreenTimeLimitsService {
  final List<ScreenTimeStatusEntry> result;
  _StubGetStatus(this.result);

  @override
  Future<List<ScreenTimeStatusEntry>> getStatus(
    String childId, {
    DateTime? date,
  }) async =>
      result;
}

class _NetworkErrorService extends ScreenTimeLimitsService {
  @override
  Future<List<ScreenTimeLimit>> getLimits(String childId) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/screen-time/limits/$childId'),
      type: DioExceptionType.connectionError,
    );
  }

  @override
  Future<ScreenTimeLimit> setLimit({
    required String childId,
    required String scope,
    required int limitSeconds,
    String? packageName,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/screen-time/limits'),
      type: DioExceptionType.connectionError,
    );
  }

  @override
  Future<void> deleteLimit(String limitId) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/screen-time/limits/$limitId'),
      type: DioExceptionType.connectionError,
    );
  }

  @override
  Future<List<ScreenTimeStatusEntry>> getStatus(
    String childId, {
    DateTime? date,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/screen-time/status/$childId'),
      type: DioExceptionType.connectionError,
    );
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('ScreenTimeLimitsService — singleton', () {
    test('instance est un singleton', () {
      expect(
        identical(
          ScreenTimeLimitsService.instance,
          ScreenTimeLimitsService.instance,
        ),
        isTrue,
      );
    });
  });

  group('getLimits', () {
    test('retourne la liste des limites', () async {
      final svc = _StubGetLimits([_fakeGlobalLimit(), _fakeAppLimit()]);
      final limits = await svc.getLimits(_childId);

      expect(limits, hasLength(2));
      expect(limits.first.scope, equals('global'));
      expect(limits.first.limitSeconds, equals(7200));
      expect(limits.last.scope, equals('app'));
      expect(limits.last.packageName, equals('com.instagram.android'));
    });

    test('retourne une liste vide si aucune limite', () async {
      final svc = _StubGetLimits([]);
      final limits = await svc.getLimits(_childId);
      expect(limits, isEmpty);
    });

    test('propage DioException sur erreur réseau', () {
      final svc = _NetworkErrorService();
      expect(
        () => svc.getLimits(_childId),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('setLimit', () {
    test('transmet les bons paramètres pour une limite globale', () async {
      String? capturedChildId;
      String? capturedScope;
      int? capturedLimit;
      String? capturedPkg;

      final svc = _StubSetLimit((cid, scope, limitSec, pkg) {
        capturedChildId = cid;
        capturedScope = scope;
        capturedLimit = limitSec;
        capturedPkg = pkg;
        return _fakeGlobalLimit();
      });

      await svc.setLimit(
        childId: _childId,
        scope: 'global',
        limitSeconds: 7200,
      );

      expect(capturedChildId, equals(_childId));
      expect(capturedScope, equals('global'));
      expect(capturedLimit, equals(7200));
      expect(capturedPkg, isNull);
    });

    test('transmet packageName pour une limite par app', () async {
      String? capturedPkg;

      final svc = _StubSetLimit((_, __, ___, pkg) {
        capturedPkg = pkg;
        return _fakeAppLimit();
      });

      await svc.setLimit(
        childId: _childId,
        scope: 'app',
        limitSeconds: 3600,
        packageName: 'com.instagram.android',
      );

      expect(capturedPkg, equals('com.instagram.android'));
    });

    test('retourne la limite créée/mise à jour', () async {
      final svc = _StubSetLimit((_, __, ___, ____) => _fakeGlobalLimit());
      final limit = await svc.setLimit(
        childId: _childId,
        scope: 'global',
        limitSeconds: 7200,
      );
      expect(limit.id, equals(_limitId));
      expect(limit.limitSeconds, equals(7200));
    });

    test('propage DioException sur erreur réseau', () {
      final svc = _NetworkErrorService();
      expect(
        () => svc.setLimit(childId: _childId, scope: 'global', limitSeconds: 3600),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('deleteLimit', () {
    test('transmet le bon limitId', () async {
      final svc = _StubDeleteLimit();
      await svc.deleteLimit(_limitId);
      expect(svc.deletedId, equals(_limitId));
    });

    test('propage DioException sur erreur réseau', () {
      final svc = _NetworkErrorService();
      expect(
        () => svc.deleteLimit(_limitId),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('getStatus', () {
    test('retourne la liste des statuts', () async {
      final svc = _StubGetStatus([_fakeStatusGlobal(), _fakeStatusApp()]);
      final status = await svc.getStatus(_childId);

      expect(status, hasLength(2));
      expect(status.first.scope, equals('global'));
      expect(status.first.usedSeconds, equals(5400));
      expect(status.first.exceeded, isFalse);
      expect(status.last.scope, equals('app'));
      expect(status.last.exceeded, isTrue);
    });

    test('retourne liste vide si aucun statut', () async {
      final svc = _StubGetStatus([]);
      final status = await svc.getStatus(_childId);
      expect(status, isEmpty);
    });

    test('propage DioException sur erreur réseau', () {
      final svc = _NetworkErrorService();
      expect(
        () => svc.getStatus(_childId),
        throwsA(isA<DioException>()),
      );
    });
  });

  // ── Régression : 200 + [] décodé en null par Dio ──────────────────────────
  // Bug : le cast (response.data as List) levait TypeError quand Dio retournait
  // null pour un body "[]". Fix : parseLimitsBody / parseStatusBody guèrent null.

  group('parseLimitsBody (fix bug 200+[])', () {
    test('retourne [] quand data est null (Dio decode [] en null)', () {
      final svc = ScreenTimeLimitsService();
      expect(svc.parseLimitsBody(null), isEmpty);
    });

    test('retourne [] quand data est une liste JSON vide', () {
      final svc = ScreenTimeLimitsService();
      expect(svc.parseLimitsBody(<dynamic>[]), isEmpty);
    });

    test('retourne [] quand data est un mauvais type (String)', () {
      final svc = ScreenTimeLimitsService();
      expect(svc.parseLimitsBody('[]'), isEmpty);
    });

    test('parse correctement une liste non vide', () {
      final svc = ScreenTimeLimitsService();
      final data = <dynamic>[
        {
          'id': _limitId,
          'child_id': _childId,
          'scope': 'global',
          'limit_seconds': 7200,
          'package_name': null,
          'app_label': null,
        }
      ];
      final limits = svc.parseLimitsBody(data);
      expect(limits, hasLength(1));
      expect(limits.first.scope, equals('global'));
      expect(limits.first.limitSeconds, equals(7200));
    });
  });

  group('parseStatusBody (fix bug 200+[])', () {
    test('retourne [] quand data est null', () {
      final svc = ScreenTimeLimitsService();
      expect(svc.parseStatusBody(null), isEmpty);
    });

    test('retourne [] quand data est une liste JSON vide', () {
      final svc = ScreenTimeLimitsService();
      expect(svc.parseStatusBody(<dynamic>[]), isEmpty);
    });

    test('retourne [] quand data est un mauvais type', () {
      final svc = ScreenTimeLimitsService();
      expect(svc.parseStatusBody(42), isEmpty);
    });

    test('parse correctement un statut non dépassé', () {
      final svc = ScreenTimeLimitsService();
      final data = <dynamic>[
        {
          'scope': 'global',
          'limit_seconds': 7200,
          'used_seconds': 3600,
          'remaining_seconds': 3600,
          'exceeded': false,
          'package_name': null,
          'app_label': null,
        }
      ];
      final entries = svc.parseStatusBody(data);
      expect(entries, hasLength(1));
      expect(entries.first.exceeded, isFalse);
      expect(entries.first.remainingSeconds, equals(3600));
    });
  });

  group('ScreenTimeLimit.fromJson', () {
    test('désérialise une limite globale complète', () {
      final json = {
        'id': _limitId,
        'child_id': _childId,
        'scope': 'global',
        'limit_seconds': 7200,
        'package_name': null,
        'app_label': null,
      };
      final limit = ScreenTimeLimit.fromJson(json);
      expect(limit.id, equals(_limitId));
      expect(limit.scope, equals('global'));
      expect(limit.limitSeconds, equals(7200));
      expect(limit.packageName, isNull);
    });

    test('désérialise une limite par app avec packageName', () {
      final json = {
        'id': '999',
        'child_id': _childId,
        'scope': 'app',
        'limit_seconds': 1800,
        'package_name': 'com.google.android.youtube',
        'app_label': 'YouTube',
      };
      final limit = ScreenTimeLimit.fromJson(json);
      expect(limit.scope, equals('app'));
      expect(limit.packageName, equals('com.google.android.youtube'));
      expect(limit.appLabel, equals('YouTube'));
    });
  });

  group('ScreenTimeStatusEntry.fromJson', () {
    test('désérialise correctement un statut non dépassé', () {
      final json = {
        'scope': 'global',
        'limit_seconds': 7200,
        'used_seconds': 3600,
        'remaining_seconds': 3600,
        'exceeded': false,
        'package_name': null,
        'app_label': null,
      };
      final status = ScreenTimeStatusEntry.fromJson(json);
      expect(status.usedSeconds, equals(3600));
      expect(status.remainingSeconds, equals(3600));
      expect(status.exceeded, isFalse);
    });

    test('désérialise correctement un statut dépassé', () {
      final json = {
        'scope': 'app',
        'limit_seconds': 1800,
        'used_seconds': 2100,
        'remaining_seconds': 0,
        'exceeded': true,
        'package_name': 'com.tiktok.android',
        'app_label': 'TikTok',
      };
      final status = ScreenTimeStatusEntry.fromJson(json);
      expect(status.exceeded, isTrue);
      expect(status.remainingSeconds, equals(0));
      expect(status.packageName, equals('com.tiktok.android'));
    });
  });
}
