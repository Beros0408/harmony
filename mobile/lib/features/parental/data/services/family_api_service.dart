import '../../../../core/services/harmony_services.dart';

// TODO : remplacer par l'id du parent authentifié (Sprint auth)
const _kParentId = 'dff545af-49e3-4250-b214-fe29e8bfa18f';

class RemoteChild {
  const RemoteChild({required this.childId, required this.fullName});
  final String childId;
  final String fullName;
}

/// Appelle GET /api/v1/family/children pour récupérer les enfants appairés
/// au parent courant depuis Supabase.
class FamilyApiService {
  FamilyApiService._();
  static final FamilyApiService instance = FamilyApiService._();

  Future<List<RemoteChild>> getChildren() async {
    final response = await HarmonyServices.dioClient.instance
        .get<List<dynamic>>(
      '/api/v1/family/children',
      queryParameters: {'parent_id': _kParentId},
    );

    final list = response.data ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(
          (m) => RemoteChild(
            childId: m['child_id'] as String,
            fullName: (m['full_name'] as String?)?.trim().isNotEmpty == true
                ? m['full_name'] as String
                : 'Enfant',
          ),
        )
        .toList();
  }
}
