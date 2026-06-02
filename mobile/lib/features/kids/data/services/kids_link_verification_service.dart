import '../../../../core/services/harmony_services.dart';

/// Vérifie auprès du backend si un child_id est encore rattaché à une famille.
/// Distingue "non lié" (linked=false) de "réseau injoignable" (exception).
class KidsLinkVerificationService {
  KidsLinkVerificationService();

  static final KidsLinkVerificationService instance =
      KidsLinkVerificationService();

  /// Retourne true si child_id est présent dans family_links, false sinon.
  /// Lance une [Exception] (ou [DioException]) si le serveur est injoignable —
  /// l'appelant doit traiter cette erreur comme "incertain, conserver l'état".
  Future<bool> isLinked(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>(
      '/api/v1/family/child-status/$childId',
    );
    return (response.data?['linked'] as bool?) ?? false;
  }
}
