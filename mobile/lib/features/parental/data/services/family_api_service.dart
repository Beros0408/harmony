import '../../../../core/services/harmony_services.dart';
import '../../../../core/session/user_session.dart';

class RemoteChild {
  const RemoteChild({required this.childId, required this.fullName});
  final String childId;
  final String fullName;
}

/// Appelle GET /api/v1/family/children pour récupérer les enfants appairés
/// au parent courant. Le parent_id provient de la session authentifiée.
class FamilyApiService {
  FamilyApiService._();
  static final FamilyApiService instance = FamilyApiService._();

  Future<List<RemoteChild>> getChildren() async {
    final parentId = UserSession.instance.parentId;
    assert(parentId != null, 'FamilyApiService: parent non authentifié');
    final response = await HarmonyServices.dioClient.instance
        .get<List<dynamic>>(
      '/api/v1/family/children',
      queryParameters: {'parent_id': parentId},
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
