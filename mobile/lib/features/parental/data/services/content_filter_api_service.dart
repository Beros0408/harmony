import '../../../../core/services/harmony_services.dart';

/// État du filtrage de contenu d'un enfant tel que retourné par le backend.
class ContentFilterState {
  const ContentFilterState({required this.childId, required this.enabled});

  final String childId;
  final bool enabled;
}

/// Service parent — lecture et écriture de l'état du filtrage DNS.
/// Appelle GET / PUT /api/v1/content-filter.
class ContentFilterApiService {
  ContentFilterApiService._();
  static final ContentFilterApiService instance = ContentFilterApiService._();

  Future<ContentFilterState> getFilterState(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>(
      '/api/v1/content-filter',
      queryParameters: {'child_id': childId},
    );
    final data = response.data ?? <String, dynamic>{};
    return ContentFilterState(
      childId: data['child_id'] as String? ?? childId,
      enabled: data['enabled'] as bool? ?? false,
    );
  }

  Future<ContentFilterState> setFilterState({
    required String childId,
    required bool enabled,
  }) async {
    final response = await HarmonyServices.dioClient.instance
        .put<Map<String, dynamic>>(
      '/api/v1/content-filter',
      data: {'child_id': childId, 'enabled': enabled},
    );
    final data = response.data ?? <String, dynamic>{};
    return ContentFilterState(
      childId: data['child_id'] as String? ?? childId,
      enabled: data['enabled'] as bool? ?? enabled,
    );
  }
}
