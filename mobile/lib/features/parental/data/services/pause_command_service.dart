import '../../../../core/services/harmony_services.dart';

/// Envoie une commande de pause/reprise à distance vers l'appareil d'un enfant.
/// Appelle POST /api/v1/commands/screen-pause ou /screen-resume avec le child_id.
class PauseCommandService {
  PauseCommandService._();
  static final PauseCommandService instance = PauseCommandService._();

  Future<void> sendPause(String childId) async {
    await HarmonyServices.dioClient.instance.post<void>(
      '/api/v1/commands/screen-pause',
      data: {'child_id': childId},
    );
  }

  Future<void> sendResume(String childId) async {
    await HarmonyServices.dioClient.instance.post<void>(
      '/api/v1/commands/screen-resume',
      data: {'child_id': childId},
    );
  }
}
