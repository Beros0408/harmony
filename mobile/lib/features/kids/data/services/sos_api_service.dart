import 'package:flutter/foundation.dart';

import '../../../../core/services/harmony_services.dart';

/// Envoie les alertes SOS de l'enfant au backend.
/// Pattern singleton identique à LocationApiService.
class SosApiService {
  SosApiService._();
  static final SosApiService instance = SosApiService._();

  /// POST /api/v1/sos/trigger
  /// childId doit être le vrai UUID issu de KidsStorage — jamais 'current'.
  /// Lance une [DioException] en cas d'erreur réseau ; l'appelant gère le catch.
  Future<void> trigger({
    required String childId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final body = <String, dynamic>{
      'child_id': childId,
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
    };

    await HarmonyServices.dioClient.instance.post<dynamic>(
      '/api/v1/sos/trigger',
      data: body,
    );

    debugPrint('[SosApiService] SOS déclenché pour $childId ($latitude, $longitude)');
  }
}
