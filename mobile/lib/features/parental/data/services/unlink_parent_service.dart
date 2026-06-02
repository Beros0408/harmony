import '../../../../core/services/harmony_services.dart';

/// Représente une demande de déliage en attente côté parent.
class UnlinkPendingItem {
  const UnlinkPendingItem({
    required this.id,
    required this.childId,
    required this.childName,
  });

  final String id;
  final String childId;
  final String childName;

  factory UnlinkPendingItem.fromJson(Map<String, dynamic> json) =>
      UnlinkPendingItem(
        id: json['id'] as String,
        childId: json['child_id'] as String,
        childName: json['child_name'] as String,
      );
}

/// Service côté parent pour gérer les demandes de déliage.
/// Interroge le backend pour les demandes en attente et envoie l'approbation/refus.
class UnlinkParentService {
  UnlinkParentService._();
  static final UnlinkParentService instance = UnlinkParentService._();

  static const _base = '/api/v1/unlink';

  /// Récupère les demandes de déliage en attente pour ce parent.
  Future<List<UnlinkPendingItem>> getPendingRequests(String parentId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<List<dynamic>>(
      '$_base/pending',
      queryParameters: {'parent_id': parentId},
    );
    final list = response.data ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(UnlinkPendingItem.fromJson)
        .toList();
  }

  /// Approuve une demande de déliage.
  Future<void> approve(String requestId, String parentId) async {
    await HarmonyServices.dioClient.instance.post<void>(
      '$_base/$requestId/approve',
      data: {'parent_id': parentId},
    );
  }

  /// Refuse une demande de déliage.
  Future<void> reject(String requestId, String parentId) async {
    await HarmonyServices.dioClient.instance.post<void>(
      '$_base/$requestId/reject',
      data: {'parent_id': parentId},
    );
  }
}
