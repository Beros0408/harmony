import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/kids/data/services/kids_pairing_service.dart';
import 'package:harmony/features/kids/logic/kids_pairing_cubit.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

class _SuccessKidsPairingService extends KidsPairingService {
  @override
  Future<KidsPairingResult> redeemCode(String code) async {
    return const KidsPairingResult(
      parentName: 'Marie',
      childName: 'Emma',
      childId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
    );
  }
}

class _NotFoundKidsPairingService extends KidsPairingService {
  @override
  Future<KidsPairingResult> redeemCode(String code) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/pairing/redeem'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/v1/pairing/redeem'),
        statusCode: 404,
      ),
      type: DioExceptionType.badResponse,
    );
  }
}

class _NetworkErrorKidsPairingService extends KidsPairingService {
  @override
  Future<KidsPairingResult> redeemCode(String code) async {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/pairing/redeem'),
      type: DioExceptionType.connectionError,
    );
  }
}

class _UnexpectedErrorKidsPairingService extends KidsPairingService {
  @override
  Future<KidsPairingResult> redeemCode(String code) async {
    throw Exception('Erreur inattendue');
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('KidsPairingCubit', () {
    test('état initial est KidsPairingInitial', () {
      expect(
        KidsPairingCubit(service: _SuccessKidsPairingService()).state,
        isA<KidsPairingInitial>(),
      );
    });

    blocTest<KidsPairingCubit, KidsPairingState>(
      'redeem("") ne change pas l\'état',
      build: () => KidsPairingCubit(service: _SuccessKidsPairingService()),
      act: (c) => c.redeem(''),
      expect: () => <KidsPairingState>[],
    );

    blocTest<KidsPairingCubit, KidsPairingState>(
      'redeem("123456") émet Loading puis Success avec parentName, childName et childId',
      build: () => KidsPairingCubit(service: _SuccessKidsPairingService()),
      act: (c) => c.redeem('123456'),
      expect: () => [
        isA<KidsPairingLoading>(),
        predicate<KidsPairingState>(
          (s) =>
              s is KidsPairingSuccess &&
              s.parentName == 'Marie' &&
              s.childName == 'Emma' &&
              s.childId == 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
          'KidsPairingSuccess parentName=Marie childName=Emma childId=uuid',
        ),
      ],
    );

    blocTest<KidsPairingCubit, KidsPairingState>(
      'redeem avec code invalide (404) émet Loading puis KidsPairingError',
      build: () => KidsPairingCubit(service: _NotFoundKidsPairingService()),
      act: (c) => c.redeem('000000'),
      expect: () => [
        isA<KidsPairingLoading>(),
        predicate<KidsPairingState>(
          (s) =>
              s is KidsPairingError &&
              s.message.contains('invalide ou expiré'),
          'KidsPairingError message contient "invalide ou expiré"',
        ),
      ],
    );

    blocTest<KidsPairingCubit, KidsPairingState>(
      'redeem avec erreur réseau émet Loading puis KidsPairingError (connexion)',
      build: () =>
          KidsPairingCubit(service: _NetworkErrorKidsPairingService()),
      act: (c) => c.redeem('123456'),
      expect: () => [
        isA<KidsPairingLoading>(),
        predicate<KidsPairingState>(
          (s) =>
              s is KidsPairingError &&
              s.message.contains('Impossible de joindre'),
          'KidsPairingError message connexion',
        ),
      ],
    );

    blocTest<KidsPairingCubit, KidsPairingState>(
      'redeem avec erreur inattendue émet Loading puis KidsPairingError générique',
      build: () =>
          KidsPairingCubit(service: _UnexpectedErrorKidsPairingService()),
      act: (c) => c.redeem('123456'),
      expect: () => [
        isA<KidsPairingLoading>(),
        predicate<KidsPairingState>(
          (s) =>
              s is KidsPairingError &&
              s.message.contains('Erreur inattendue'),
          'KidsPairingError inattendue',
        ),
      ],
    );

    blocTest<KidsPairingCubit, KidsPairingState>(
      'reset() depuis Success repasse en Initial',
      build: () => KidsPairingCubit(service: _SuccessKidsPairingService()),
      act: (c) async {
        await c.redeem('123456');
        c.reset();
      },
      expect: () => [
        isA<KidsPairingLoading>(),
        isA<KidsPairingSuccess>(),
        isA<KidsPairingInitial>(),
      ],
    );

    blocTest<KidsPairingCubit, KidsPairingState>(
      'redeem("  123456  ") normalise le code (trim)',
      build: () => KidsPairingCubit(service: _SuccessKidsPairingService()),
      act: (c) => c.redeem('  123456  '),
      expect: () => [
        isA<KidsPairingLoading>(),
        isA<KidsPairingSuccess>(),
      ],
    );
  });
}
