import 'package:dio/dio.dart';
import '../../../../core/services/harmony_services.dart';

/// Enregistre le consentement RGPD du parent via PUT /api/v1/consent.
class ConsentService {
  const ConsentService._();
  static const ConsentService instance = ConsentService._();

  Future<void> recordConsent({
    required String parentId,
    required String consentType,
    required bool granted,
    required String policyVersion,
    String? childId,
  }) async {
    await HarmonyServices.dioClient.instance.put<void>(
      '/api/v1/consent',
      data: {
        'parent_id': parentId,
        if (childId != null) 'child_id': childId,
        'consent_type': consentType,
        'granted': granted,
        'policy_version': policyVersion,
      },
      options: Options(validateStatus: (status) => status != null && status < 500),
    );
  }
}
