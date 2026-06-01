import '../../../../core/services/harmony_services.dart';

class PairingResult {
  const PairingResult({
    required this.code,
    required this.childName,
    required this.expiresAt,
  });

  final String code;
  final String childName;
  final DateTime expiresAt;
}

/// Appelle POST /api/v1/pairing/generate sur le backend FastAPI.
/// parent_id doit être un UUID valide côté backend.
/// TODO: remplacer par l'id du parent authentifié.
const _kParentId = 'dff545af-49e3-4250-b214-fe29e8bfa18f';

class PairingService {
  PairingService();

  static final PairingService instance = PairingService();

  Future<PairingResult> generatePairingCode(String childName) async {
    final response = await HarmonyServices.dioClient.instance
        .post<Map<String, dynamic>>(
      '/api/v1/pairing/generate',
      data: {
        'child_name': childName.trim(),
        'parent_id': _kParentId,
      },
    );

    final data = response.data!;
    return PairingResult(
      code: data['code'] as String,
      childName: data['child_name'] as String,
      // expires_at est un ISO-8601 UTC — convertir en heure locale
      expiresAt: DateTime.parse(data['expires_at'] as String).toLocal(),
    );
  }
}
