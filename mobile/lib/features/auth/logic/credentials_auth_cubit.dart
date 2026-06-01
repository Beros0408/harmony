import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/services/auth_credentials_service.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class CredentialsAuthState extends Equatable {
  const CredentialsAuthState();
  @override
  List<Object?> get props => [];
}

class CredentialsAuthInitial extends CredentialsAuthState {
  const CredentialsAuthInitial();
}

class CredentialsAuthLoading extends CredentialsAuthState {
  const CredentialsAuthLoading();
}

/// Erreur de connexion ou d'inscription (réseau, validation, etc.)
class CredentialsAuthError extends CredentialsAuthState {
  const CredentialsAuthError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

/// Gère les états UI des écrans de connexion et d'inscription.
/// En cas de succès, [UserSession] est mis à jour par [AuthCredentialsService],
/// ce qui déclenche le redirect GoRouter vers le dashboard — aucun état Success.
class CredentialsAuthCubit extends Cubit<CredentialsAuthState> {
  CredentialsAuthCubit({AuthCredentialsService? service})
      : _service = service ?? AuthCredentialsService.instance,
        super(const CredentialsAuthInitial());

  final AuthCredentialsService _service;

  Future<void> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.isEmpty) {
      emit(const CredentialsAuthError('Veuillez remplir tous les champs.'));
      return;
    }
    emit(const CredentialsAuthLoading());
    try {
      await _service.login(email: email.trim(), password: password);
    } on DioException catch (e) {
      emit(CredentialsAuthError(_dioMessage(e)));
    } catch (_) {
      emit(const CredentialsAuthError('Erreur inattendue. Réessayez.'));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (email.trim().isEmpty || password.isEmpty || fullName.trim().isEmpty) {
      emit(const CredentialsAuthError('Veuillez remplir tous les champs.'));
      return;
    }
    emit(const CredentialsAuthLoading());
    try {
      await _service.register(
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
      );
    } on DioException catch (e) {
      emit(CredentialsAuthError(_dioMessage(e)));
    } catch (_) {
      emit(const CredentialsAuthError('Erreur inattendue. Réessayez.'));
    }
  }

  void reset() => emit(const CredentialsAuthInitial());

  String _dioMessage(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) return 'Email ou mot de passe incorrect.';
    if (statusCode == 409) return 'Un compte avec cet email existe déjà.';
    if (statusCode == 422) return _parsePydanticError(e) ?? 'Données invalides.';
    if (statusCode != null && statusCode >= 500) {
      return 'Erreur serveur. Réessayez dans quelques instants.';
    }
    final type = e.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }
    return 'Erreur réseau. Réessayez.';
  }

  String? _parsePydanticError(DioException e) {
    final detail = e.response?.data;
    if (detail is Map<String, dynamic> && detail['detail'] is List) {
      final errors =
          (detail['detail'] as List).whereType<Map<String, dynamic>>().toList();
      if (errors.isNotEmpty) {
        final msg = errors.first['msg'];
        if (msg is String) return msg;
      }
    }
    return null;
  }
}
