import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/services/kids_pairing_service.dart';

// ─── États ───────────────────────────────────────────────────────────────────

abstract class KidsPairingState extends Equatable {
  const KidsPairingState();

  @override
  List<Object?> get props => [];
}

class KidsPairingInitial extends KidsPairingState {
  const KidsPairingInitial();
}

class KidsPairingLoading extends KidsPairingState {
  const KidsPairingLoading();
}

class KidsPairingSuccess extends KidsPairingState {
  const KidsPairingSuccess({
    required this.parentName,
    required this.childName,
  });

  final String parentName;
  final String childName;

  @override
  List<Object?> get props => [parentName, childName];
}

class KidsPairingError extends KidsPairingState {
  const KidsPairingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class KidsPairingCubit extends Cubit<KidsPairingState> {
  KidsPairingCubit({KidsPairingService? service})
      : _service = service ?? KidsPairingService.instance,
        super(const KidsPairingInitial());

  final KidsPairingService _service;

  Future<void> redeem(String code) async {
    final cleaned = code.trim();
    if (cleaned.isEmpty) return;

    emit(const KidsPairingLoading());
    try {
      final result = await _service.redeemCode(cleaned);
      emit(
        KidsPairingSuccess(
          parentName: result.parentName,
          childName: result.childName,
        ),
      );
    } on DioException catch (e) {
      emit(KidsPairingError(_dioMessage(e)));
    } catch (_) {
      emit(const KidsPairingError('Erreur inattendue. Réessayez.'));
    }
  }

  void reset() => emit(const KidsPairingInitial());

  String _dioMessage(DioException e) {
    final type = e.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.connectionError) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 404) return 'Code invalide ou expiré. Demande un nouveau code au parent.';
    if (statusCode == 422) return 'Format de code invalide. Vérifie les 6 chiffres.';
    if (statusCode != null && statusCode >= 500) {
      return 'Erreur serveur. Réessayez dans quelques instants.';
    }
    return 'Erreur réseau (${statusCode ?? 'inconnue'}).';
  }
}
