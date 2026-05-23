import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Aucun PIN configuré — affiche le flux de création de PIN
class AuthPinSetup extends AuthState {
  const AuthPinSetup();
}

/// PIN configuré — affiche l'écran de saisie (+ biométrie si disponible)
class AuthPinEntry extends AuthState {
  const AuthPinEntry({
    required this.biometricAvailable,
    required this.biometricEnabled,
  });
  final bool biometricAvailable;
  final bool biometricEnabled;

  @override
  List<Object?> get props => [biometricAvailable, biometricEnabled];
}

/// Activation de la biométrie proposée après configuration du PIN
class AuthBiometricSetup extends AuthState {
  const AuthBiometricSetup();
}

/// Authentification réussie
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

/// PIN incorrect
class AuthPinError extends AuthState {
  const AuthPinError({required this.attemptsLeft});
  final int attemptsLeft;

  @override
  List<Object?> get props => [attemptsLeft];
}

/// Erreur générique
class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
