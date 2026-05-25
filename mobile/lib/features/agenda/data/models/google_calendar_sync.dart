import 'package:equatable/equatable.dart';

class GoogleCalendarSync extends Equatable {
  const GoogleCalendarSync({
    required this.id,
    required this.accountEmail,
    this.lastSyncAt,
    this.nextSyncToken,
  });

  final String id;
  final String accountEmail;
  final DateTime? lastSyncAt;
  final String? nextSyncToken;

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() => {
        'id': id,
        'account_email': accountEmail,
        'last_sync_at': lastSyncAt?.millisecondsSinceEpoch,
        'next_sync_token': nextSyncToken,
      };

  factory GoogleCalendarSync.fromMap(Map<String, dynamic> m) =>
      GoogleCalendarSync(
        id: m['id'] as String,
        accountEmail: m['account_email'] as String,
        lastSyncAt: m['last_sync_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(m['last_sync_at'] as int)
            : null,
        nextSyncToken: m['next_sync_token'] as String?,
      );
}
