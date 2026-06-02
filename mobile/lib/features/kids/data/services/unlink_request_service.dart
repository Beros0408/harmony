import '../../../../core/services/harmony_services.dart';

/// Résultat du statut d'une demande de déliage côté enfant.
class UnlinkStatusResult {
  const UnlinkStatusResult({required this.status, this.requestId});

  /// 'none' | 'pending' | 'approved' | 'rejected'
  final String status;
  final String? requestId;
}

/// Service côté enfant pour le déliage d'appareil.
/// Crée une demande, interroge son statut et confirme l'exécution au backend.
class UnlinkRequestService {
  UnlinkRequestService._();
  static final UnlinkRequestService instance = UnlinkRequestService._();

  static const _base = '/api/v1/unlink';

  /// Envoie une demande de déliage au backend.
  /// Le backend récupère le parent_id via family_links et crée l'enregistrement.
  /// Renvoie le request_id de la demande créée.
  Future<String> createRequest(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .post<Map<String, dynamic>>(
      '$_base/request',
      data: {'child_id': childId},
    );
    return response.data!['request_id'] as String;
  }

  /// Interroge le statut de la demande en cours pour cet enfant.
  /// Utilisé par le polling pour détecter l'approbation ou le refus.
  Future<UnlinkStatusResult> getStatus(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>(
      '$_base/status',
      queryParameters: {'child_id': childId},
    );
    final data = response.data!;
    return UnlinkStatusResult(
      status: data['status'] as String,
      requestId: data['request_id'] as String?,
    );
  }

  /// Confirme l'exécution du déliage côté backend :
  /// supprime family_links et purge la demande.
  Future<void> executeUnlink(String requestId, String childId) async {
    await HarmonyServices.dioClient.instance.post<void>(
      '$_base/$requestId/execute',
      data: {'child_id': childId},
    );
  }
}
