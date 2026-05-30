import '../../../../core/services/harmony_services.dart';

/// Envoie une commande de verrouillage d'écran vers l'appareil d'un enfant.
/// Appelle POST /api/v1/commands/lock avec le child_id concerné.
class LockCommandService {
  LockCommandService._();
  static final LockCommandService instance = LockCommandService._();

  Future<void> sendLock(String childId) async {
    await HarmonyServices.dioClient.instance.post<void>(
      '/api/v1/commands/lock',
      data: {'child_id': childId},
    );
  }
}
