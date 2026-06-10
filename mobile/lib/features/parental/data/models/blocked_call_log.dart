class BlockedCallLog {
  const BlockedCallLog({
    required this.id,
    required this.phoneNumber,
    required this.blockedAt,
    required this.listMode,
    this.latencyMs,
  });

  final String id;
  final String phoneNumber;
  final DateTime blockedAt;
  final String listMode;
  final int? latencyMs;

  factory BlockedCallLog.fromJson(Map<String, dynamic> j) => BlockedCallLog(
        id: j['id'] as String,
        phoneNumber: j['phone_number'] as String,
        blockedAt: DateTime.parse(j['blocked_at'] as String).toLocal(),
        listMode: j['list_mode'] as String? ?? 'blacklist',
        latencyMs: j['latency_ms'] as int?,
      );
}
