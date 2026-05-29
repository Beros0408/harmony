import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/services/pairing_service.dart';

// ─── States ──────────────────────────────────────────────────────────────────

abstract class PairingState extends Equatable {
  const PairingState();

  @override
  List<Object?> get props => [];
}

class PairingInitial extends PairingState {
  const PairingInitial();
}

class PairingLoading extends PairingState {
  const PairingLoading();
}

class PairingSuccess extends PairingState {
  const PairingSuccess({
    required this.code,
    required this.childName,
    required this.expiresAt,
  });

  final String code;
  final String childName;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [code, childName, expiresAt];
}

class PairingError extends PairingState {
  const PairingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class PairingCubit extends Cubit<PairingState> {
  PairingCubit({PairingService? service})
      : _service = service ?? PairingService.instance,
        super(const PairingInitial());

  final PairingService _service;

  Future<void> generate(String childName) async {
    final name = childName.trim();
    if (name.isEmpty) return;

    emit(const PairingLoading());
    try {
      final result = await _service.generatePairingCode(name);
      emit(
        PairingSuccess(
          code: result.code,
          childName: result.childName,
          expiresAt: result.expiresAt,
        ),
      );
    } on DioException catch (e) {
      emit(PairingError(_dioMessage(e)));
    } catch (_) {
      emit(const PairingError('Erreur inattendue. Réessayez.'));
    }
  }

  String _dioMessage(DioException e) {
    final type = e.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 422) return 'Prénom invalide ou identifiant manquant.';
    if (statusCode != null && statusCode >= 500) {
      return 'Erreur serveur. Réessayez dans quelques instants.';
    }
    return 'Erreur réseau (${statusCode ?? 'inconnue'}).';
  }
}
