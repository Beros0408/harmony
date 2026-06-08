import 'package:dio/dio.dart';

import '../../../../core/services/harmony_services.dart';
import '../models/location_point.dart';

class ChildLocationFetchService {
  ChildLocationFetchService._();
  static final ChildLocationFetchService instance = ChildLocationFetchService._();

  /// Dernière position GPS de l'enfant depuis le backend.
  /// Retourne null si aucune position n'existe encore ou en cas d'erreur réseau.
  Future<LocationPoint?> fetchLatest(String childId) async {
    try {
      final response = await HarmonyServices.dioClient.instance
          .get<Map<String, dynamic>>('/api/v1/locations/latest/$childId');
      if (response.data == null) return null;
      return LocationPoint.fromJson(response.data!);
    } on DioException {
      return null;
    }
  }

  /// Historique des N dernières positions GPS de l'enfant (récents d'abord).
  /// Retourne une liste vide en cas d'erreur réseau ou d'absence de données.
  Future<List<LocationPoint>> fetchHistory(String childId, {int limit = 50}) async {
    try {
      final response = await HarmonyServices.dioClient.instance
          .get<Map<String, dynamic>>(
        '/api/v1/locations/history/$childId',
        queryParameters: {'limit': limit},
      );
      if (response.data == null) return [];
      final points = response.data!['points'] as List<dynamic>? ?? [];
      return points
          .whereType<Map<String, dynamic>>()
          .map(LocationPoint.fromJson)
          .toList();
    } on DioException {
      return [];
    }
  }
}
