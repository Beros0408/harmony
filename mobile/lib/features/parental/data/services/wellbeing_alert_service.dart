import '../../../../core/services/harmony_services.dart';

// ─── Modèle ──────────────────────────────────────────────────────────────────

class WellbeingAlert {
  const WellbeingAlert({
    required this.id,
    required this.childId,
    required this.signalId,
    required this.title,
    required this.message,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String childId;
  final String signalId;
  final String title;
  final String message;
  // 'info' | 'vigilance' | 'attention'
  final String severity;
  // 'sent' | 'read' | 'handled'
  final String status;
  // Converti en heure locale dès la désérialisation (created_at arrive en UTC)
  final DateTime createdAt;
  final DateTime? readAt;

  // Seul 'sent' requiert une action du parent ; 'read' et 'handled' sont traités
  bool get isPending => status == 'sent';

  factory WellbeingAlert.fromJson(Map<String, dynamic> j) => WellbeingAlert(
        id: j['id'] as String,
        childId: j['child_id'] as String,
        signalId: j['signal_id'] as String,
        title: j['title'] as String,
        message: j['message'] as String,
        severity: j['severity'] as String,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
        readAt: j['read_at'] != null
            ? DateTime.parse(j['read_at'] as String).toLocal()
            : null,
      );
}

// ─── Service ─────────────────────────────────────────────────────────────────

class WellbeingAlertService {
  WellbeingAlertService._();
  static final WellbeingAlertService instance = WellbeingAlertService._();

  Future<List<WellbeingAlert>> getAlerts(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<List<dynamic>>('/api/v1/wellbeing/alerts/$childId');
    final list = response.data ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(WellbeingAlert.fromJson)
        .toList();
  }

  Future<void> markRead(String alertId) async {
    await HarmonyServices.dioClient.instance
        .post<void>('/api/v1/wellbeing/alerts/$alertId/read');
  }
}
