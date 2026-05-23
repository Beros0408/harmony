import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:harmony/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:harmony/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:harmony/features/auth/presentation/bloc/auth_event.dart';
import 'package:harmony/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  AuthBloc buildBloc() => AuthBloc(repository: repository);

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'émet AuthPinSetup quand aucun PIN configuré',
      build: buildBloc,
      setUp: () {
        when(() => repository.isPinSet()).thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthPinSetup()],
    );

    blocTest<AuthBloc, AuthState>(
      'émet AuthPinEntry quand PIN configuré sans biométrie',
      build: buildBloc,
      setUp: () {
        when(() => repository.isPinSet()).thenAnswer((_) async => true);
        when(() => repository.isBiometricAvailable()).thenAnswer((_) async => false);
        when(() => repository.isBiometricEnabled()).thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthPinEntry(biometricAvailable: false, biometricEnabled: false),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'déclenche biométrie automatiquement si activée',
      build: buildBloc,
      setUp: () {
        when(() => repository.isPinSet()).thenAnswer((_) async => true);
        when(() => repository.isBiometricAvailable()).thenAnswer((_) async => true);
        when(() => repository.isBiometricEnabled()).thenAnswer((_) async => true);
        when(() => repository.authenticateWithBiometric()).thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthPinEntry(biometricAvailable: true, biometricEnabled: true),
        const AuthAuthenticated(),
      ],
    );
  });

  group('AuthPinSetupRequested', () {
    blocTest<AuthBloc, AuthState>(
      'émet AuthBiometricSetup si biométrie disponible après configuration',
      build: buildBloc,
      setUp: () {
        when(() => repository.setPin(any())).thenAnswer((_) async {});
        when(() => repository.isBiometricAvailable()).thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const AuthPinSetupRequested('1234')),
      expect: () => [const AuthLoading(), const AuthBiometricSetup()],
      verify: (_) => verify(() => repository.setPin('1234')).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'émet AuthAuthenticated directement si biométrie indisponible',
      build: buildBloc,
      setUp: () {
        when(() => repository.setPin(any())).thenAnswer((_) async {});
        when(() => repository.isBiometricAvailable()).thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const AuthPinSetupRequested('5678')),
      expect: () => [const AuthLoading(), const AuthAuthenticated()],
    );
  });

  group('AuthPinSubmitted', () {
    blocTest<AuthBloc, AuthState>(
      'émet AuthAuthenticated pour PIN correct',
      build: buildBloc,
      setUp: () {
        when(() => repository.verifyPin('1234')).thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const AuthPinSubmitted('1234')),
      expect: () => [const AuthAuthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'émet AuthPinError pour PIN incorrect',
      build: buildBloc,
      setUp: () {
        when(() => repository.verifyPin(any())).thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const AuthPinSubmitted('0000')),
      expect: () => [const AuthPinError(attemptsLeft: 4)],
    );

    blocTest<AuthBloc, AuthState>(
      'décrémente attemptsLeft à chaque échec',
      build: buildBloc,
      setUp: () {
        when(() => repository.verifyPin(any())).thenAnswer((_) async => false);
      },
      act: (bloc) async {
        bloc.add(const AuthPinSubmitted('0000'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AuthPinSubmitted('1111'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AuthPinSubmitted('2222'));
      },
      expect: () => [
        const AuthPinError(attemptsLeft: 4),
        const AuthPinError(attemptsLeft: 3),
        const AuthPinError(attemptsLeft: 2),
      ],
    );
  });

  group('AuthBiometricRequested', () {
    blocTest<AuthBloc, AuthState>(
      'émet AuthAuthenticated si biométrie acceptée',
      build: buildBloc,
      setUp: () {
        when(() => repository.authenticateWithBiometric()).thenAnswer((_) async => true);
      },
      act: (bloc) => bloc.add(const AuthBiometricRequested()),
      expect: () => [const AuthAuthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'ne change pas d\'état si biométrie refusée (annulation utilisateur)',
      build: buildBloc,
      setUp: () {
        when(() => repository.authenticateWithBiometric()).thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const AuthBiometricRequested()),
      expect: () => <AuthState>[],
    );
  });

  group('AuthBiometricToggled', () {
    blocTest<AuthBloc, AuthState>(
      'émet AuthAuthenticated après activation biométrie',
      build: buildBloc,
      setUp: () {
        when(() => repository.setBiometricEnabled(enabled: true))
            .thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const AuthBiometricToggled(enabled: true)),
      expect: () => [const AuthAuthenticated()],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'émet AuthPinEntry sans réinitialiser le PIN',
      build: buildBloc,
      setUp: () {
        when(() => repository.isBiometricAvailable()).thenAnswer((_) async => false);
        when(() => repository.isBiometricEnabled()).thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthPinEntry(biometricAvailable: false, biometricEnabled: false),
      ],
      verify: (_) => verifyNever(() => repository.clearPin()),
    );
  });
}
