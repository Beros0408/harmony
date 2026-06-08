import '../../../../core/services/harmony_services.dart';

// ─── Modèle ──────────────────────────────────────────────────────────────────

class SosEvent {
  const SosEvent({
    required this.id,
    required this.childId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.triggeredAt,
    required this.status,
  });

  final String id;
  final String childId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  // Converti en heure locale dès la désérialisation (triggered_at arrive en UTC)
  final DateTime triggeredAt;
  // 'active' | 'acknowledged'
  final String status;

  factory SosEvent.fromJson(Map<String, dynamic> j) => SosEvent(
        id: j['id'] as String,
        childId: j['child_id'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        accuracy: j['accuracy'] != null ? (j['accuracy'] as num).toDouble() : null,
        triggeredAt: DateTime.parse(j['triggered_at'] as String).toLocal(),
        status: j['status'] as String,
      );
}

// ─── Service ─────────────────────────────────────────────────────────────────

class SosAlertService {
  SosAlertService._();
  static final SosAlertService instance = SosAlertService._();

  /// GET /api/v1/sos/active/{childId}
  /// Retourne la liste des events actifs (réponse : { child_id, events: [...] }).
  Future<List<SosEvent>> getActiveSos(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>('/api/v1/sos/active/$childId');
    final data = response.data ?? {};
    final events = (data['events'] as List<dynamic>?) ?? [];
    return events
        .whereType<Map<String, dynamic>>()
        .map(SosEvent.fromJson)
        .toList();
  }

  /// POST /api/v1/sos/{eventId}/acknowledge
  Future<void> acknowledge(String eventId) async {
    await HarmonyServices.dioClient.instance
        .post<void>('/api/v1/sos/$eventId/acknowledge');
  }
}
