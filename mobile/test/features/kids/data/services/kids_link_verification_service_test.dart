import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/kids/data/services/kids_link_verification_service.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

class _LinkedService extends KidsLinkVerificationService {
  @override
  Future<bool> isLinked(String childId) async => true;
}

class _UnlinkedService extends KidsLinkVerificationService {
  @override
  Future<bool> isLinked(String childId) async => false;
}

class _NetworkErrorService extends KidsLinkVerificationService {
  @override
  Future<bool> isLinked(String childId) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/family/child-status/test'),
      type: DioExceptionType.connectionError,
    );
  }
}

class _TimeoutService extends KidsLinkVerificationService {
  @override
  Future<bool> isLinked(String childId) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/family/child-status/test'),
      type: DioExceptionType.connectionTimeout,
    );
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('KidsLinkVerificationService', () {
    test('instance est un singleton', () {
      expect(
        identical(
          KidsLinkVerificationService.instance,
          KidsLinkVerificationService.instance,
        ),
        isTrue,
      );
    });

    test('isLinked retourne true quand le lien existe', () async {
      final svc = _LinkedService();
      expect(await svc.isLinked('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'), isTrue);
    });

    test('isLinked retourne false quand le lien est supprimé', () async {
      final svc = _UnlinkedService();
      expect(
        await svc.isLinked('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'),
        isFalse,
      );
    });

    test('isLinked lance DioException sur erreur réseau (connectionError)', () {
      final svc = _NetworkErrorService();
      expect(
        () => svc.isLinked('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'),
        throwsA(isA<DioException>()),
      );
    });

    test('isLinked lance DioException sur timeout', () {
      final svc = _TimeoutService();
      expect(
        () => svc.isLinked('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
