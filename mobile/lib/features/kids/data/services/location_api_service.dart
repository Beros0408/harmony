import 'package:flutter/foundation.dart';

import '../../../../core/services/harmony_services.dart';

/// Envoie les positions GPS de l'enfant au backend.
/// Pattern singleton identique aux autres services kids (ScreenTimeUploadService, etc.).
class LocationApiService {
  LocationApiService._();
  static final LocationApiService instance = LocationApiService._();

  /// POST /api/v1/locations/{childId}
  /// childId doit être le vrai UUID issu de KidsStorage — jamais 'current'.
  /// Lance une [DioException] en cas d'erreur réseau ; l'appelant gère le catch.
  Future<void> sendPosition({
    required String childId,
    required double latitude,
    required double longitude,
    double? accuracy,
    DateTime? recordedAt,
  }) async {
    final body = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (recordedAt != null) 'recorded_at': recordedAt.toUtc().toIso8601String(),
    };

    await HarmonyServices.dioClient.instance.post<dynamic>(
      '/api/v1/locations/$childId',
      data: body,
    );

    debugPrint('[LocationApiService] position envoyée pour $childId ($latitude, $longitude)');
  }
}
