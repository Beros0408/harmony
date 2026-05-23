import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

// Nombre maximal de tentatives PIN avant verrouillage temporaire
const int _maxAttempts = 5;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required IAuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthPinSetupRequested>(_onPinSetup);
    on<AuthPinSubmitted>(_onPinSubmitted);
    on<AuthBiometricRequested>(_onBiometricRequested);
    on<AuthBiometricToggled>(_onBiometricToggled);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final IAuthRepository _repository;
  int _failedAttempts = 0;

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final pinSet = await _repository.isPinSet();
      if (!pinSet) {
        emit(const AuthPinSetup());
        return;
      }
      final biometricAvailable = await _repository.isBiometricAvailable();
      final biometricEnabled = await _repository.isBiometricEnabled();
      emit(
        AuthPinEntry(
          biometricAvailable: biometricAvailable,
          biometricEnabled: biometricEnabled,
        ),
      );
      // Déclenchement automatique de la biométrie si activée
      if (biometricAvailable && biometricEnabled) {
        add(const AuthBiometricRequested());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPinSetup(
    AuthPinSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _repository.setPin(event.pin);
      final biometricAvailable = await _repository.isBiometricAvailable();
      if (biometricAvailable) {
        emit(const AuthBiometricSetup());
      } else {
        emit(const AuthAuthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPinSubmitted(
    AuthPinSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final valid = await _repository.verifyPin(event.pin);
      if (valid) {
        _failedAttempts = 0;
        emit(const AuthAuthenticated());
      } else {
        _failedAttempts++;
        emit(AuthPinError(attemptsLeft: _maxAttempts - _failedAttempts));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onBiometricRequested(
    AuthBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final success = await _repository.authenticateWithBiometric();
      if (success) {
        _failedAttempts = 0;
        emit(const AuthAuthenticated());
      }
      // Silence si l'utilisateur annule — reste sur l'écran PIN
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onBiometricToggled(
    AuthBiometricToggled event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _repository.setBiometricEnabled(enabled: event.enabled);
      emit(const AuthAuthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _failedAttempts = 0;
    final biometricAvailable = await _repository.isBiometricAvailable();
    final biometricEnabled = await _repository.isBiometricEnabled();
    emit(
      AuthPinEntry(
        biometricAvailable: biometricAvailable,
        biometricEnabled: biometricEnabled,
      ),
    );
  }
}
