import 'package:equatable/equatable.dart';

/// Source applicative d'un message capturé.
enum MessageSource {
  sms,
  whatsApp,
  signal,
  telegram,
  unknown;

  String get displayName => switch (this) {
        MessageSource.sms => 'SMS',
        MessageSource.whatsApp => 'WhatsApp',
        MessageSource.signal => 'Signal',
        MessageSource.telegram => 'Telegram',
        MessageSource.unknown => 'Inconnu',
      };

  /// Identifiant de package Android associé à chaque source.
  String? get packageName => switch (this) {
        MessageSource.whatsApp => 'com.whatsapp',
        MessageSource.signal => 'org.thoughtcrime.securesms',
        MessageSource.telegram => 'org.telegram.messenger',
        _ => null,
      };

  static MessageSource fromPackage(String package) => switch (package) {
        'com.whatsapp' => MessageSource.whatsApp,
        'org.thoughtcrime.securesms' => MessageSource.signal,
        'org.telegram.messenger' => MessageSource.telegram,
        _ => MessageSource.unknown,
      };
}

/// Un message entrant capturé par le NotificationListener ou le ContentObserver SMS.
class CapturedMessage extends Equatable {
  const CapturedMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.source,
    this.isBlocked = false,
    this.blockReason,
  });

  final String id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final MessageSource source;
  final bool isBlocked;

  /// Raison du blocage si isBlocked == true.
  final String? blockReason;

  CapturedMessage copyWith({
    String? id,
    String? sender,
    String? content,
    DateTime? timestamp,
    MessageSource? source,
    bool? isBlocked,
    String? blockReason,
  }) =>
      CapturedMessage(
        id: id ?? this.id,
        sender: sender ?? this.sender,
        content: content ?? this.content,
        timestamp: timestamp ?? this.timestamp,
        source: source ?? this.source,
        isBlocked: isBlocked ?? this.isBlocked,
        blockReason: blockReason ?? this.blockReason,
      );

  factory CapturedMessage.fromMap(Map<String, dynamic> map) => CapturedMessage(
        id: map['id'] as String? ?? '',
        sender: map['sender'] as String? ?? '',
        content: map['content'] as String? ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (map['timestamp'] as int?) ?? 0,
        ),
        source: MessageSource.fromPackage(map['packageName'] as String? ?? ''),
        isBlocked: (map['isBlocked'] as bool?) ?? false,
        blockReason: map['blockReason'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sender': sender,
        'content': content,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'packageName': source.packageName ?? '',
        'isBlocked': isBlocked,
        'blockReason': blockReason,
      };

  @override
  List<Object?> get props =>
      [id, sender, content, timestamp, source, isBlocked, blockReason];
}
