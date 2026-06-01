import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/core/session/user_session.dart';
import 'package:harmony/features/auth/data/services/auth_credentials_service.dart';
import 'package:harmony/features/auth/logic/credentials_auth_cubit.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

class _SuccessService extends AuthCredentialsService {
  @override
  Future<void> login({required String email, required String password}) async {
    UserSession.instance.update(
      parentId: 'test-parent-uuid',
      email: email,
      fullName: 'Parent Test',
    );
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    UserSession.instance.update(
      parentId: 'test-parent-uuid',
      email: email,
      fullName: fullName,
    );
  }

  @override
  Future<void> logout() async {}
}

Response<dynamic> _fakeResponse(int code, [Object? data]) => Response(
      requestOptions: RequestOptions(),
      statusCode: code,
      data: data,
    );

class _Failing401Service extends AuthCredentialsService {
  @override
  Future<void> login({required String email, required String password}) async {
    throw DioException(
      requestOptions: RequestOptions(),
      response: _fakeResponse(401),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {}

  @override
  Future<void> logout() async {}
}

class _Failing409Service extends AuthCredentialsService {
  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(),
      response: _fakeResponse(409),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<void> logout() async {}
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  tearDown(() => UserSession.instance.clear());

  group('CredentialsAuthCubit — login', () {
    blocTest<CredentialsAuthCubit, CredentialsAuthState>(
      'email vide → CredentialsAuthError sans appel réseau',
      build: () => CredentialsAuthCubit(service: _SuccessService()),
      act: (c) => c.login(email: '', password: 'Test1234'),
      expect: () => [isA<CredentialsAuthError>()],
    );

    blocTest<CredentialsAuthCubit, CredentialsAuthState>(
      'mot de passe vide → CredentialsAuthError sans appel réseau',
      build: () => CredentialsAuthCubit(service: _SuccessService()),
      act: (c) => c.login(email: 'test@test.com', password: ''),
      expect: () => [isA<CredentialsAuthError>()],
    );

    blocTest<CredentialsAuthCubit, CredentialsAuthState>(
      'succès → émet Loading puis reste en Loading (GoRouter redirige)',
      build: () => CredentialsAuthCubit(service: _SuccessService()),
      act: (c) => c.login(email: 'test@test.com', password: 'Test1234'),
      expect: () => [isA<CredentialsAuthLoading>()],
      verify: (_) {
        expect(UserSession.instance.isAuthenticated, isTrue);
        expect(UserSession.instance.parentId, equals('test-parent-uuid'));
      },
    );

    blocTest<CredentialsAuthCubit, CredentialsAuthState>(
      '401 → CredentialsAuthError "Email ou mot de passe incorrect."',
      build: () => CredentialsAuthCubit(service: _Failing401Service()),
      act: (c) => c.login(email: 'test@test.com', password: 'Wrong1234'),
      expect: () => [
        isA<CredentialsAuthLoading>(),
        predicate<CredentialsAuthState>(
          (s) =>
              s is CredentialsAuthError &&
              s.message == 'Email ou mot de passe incorrect.',
          'CredentialsAuthError 401',
        ),
      ],
    );
  });

  group('CredentialsAuthCubit — register', () {
    blocTest<CredentialsAuthCubit, CredentialsAuthState>(
      'champ vide → CredentialsAuthError',
      build: () => CredentialsAuthCubit(service: _SuccessService()),
      act: (c) => c.register(email: '', password: 'Test1234', fullName: 'Marie'),
      expect: () => [isA<CredentialsAuthError>()],
    );

    blocTest<CredentialsAuthCubit, CredentialsAuthState>(
      'succès → émet Loading, UserSession mis à jour',
      build: () => CredentialsAuthCubit(service: _SuccessService()),
      act: (c) => c.register(
        email: 'new@test.com',
        password: 'Test1234',
        fullName: 'Marie',
      ),
      expect: () => [isA<CredentialsAuthLoading>()],
      verify: (_) {
        expect(UserSession.instance.isAuthenticated, isTrue);
        expect(UserSession.instance.email, equals('new@test.com'));
      },
    );

    blocTest<CredentialsAuthCubit, CredentialsAuthState>(
      '409 → CredentialsAuthError "Un compte avec cet email existe déjà."',
      build: () => CredentialsAuthCubit(service: _Failing409Service()),
      act: (c) => c.register(
        email: 'existing@test.com',
        password: 'Test1234',
        fullName: 'Marie',
      ),
      expect: () => [
        isA<CredentialsAuthLoading>(),
        predicate<CredentialsAuthState>(
          (s) =>
              s is CredentialsAuthError &&
              s.message == 'Un compte avec cet email existe déjà.',
          'CredentialsAuthError 409',
        ),
      ],
    );
  });

  group('CredentialsAuthCubit — reset', () {
    blocTest<CredentialsAuthCubit, CredentialsAuthState>(
      'reset depuis Error → CredentialsAuthInitial',
      build: () => CredentialsAuthCubit(service: _Failing401Service()),
      act: (c) async {
        await c.login(email: 'x@x.com', password: 'Wrong1234');
        c.reset();
      },
      expect: () => [
        isA<CredentialsAuthLoading>(),
        isA<CredentialsAuthError>(),
        isA<CredentialsAuthInitial>(),
      ],
    );
  });
}
