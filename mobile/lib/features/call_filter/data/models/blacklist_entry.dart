import 'package:equatable/equatable.dart';

enum BlockReason { spam, telemarketing, harassment, other }

/// Un numéro bloqué persisté en SQLCipher.
class BlacklistEntry extends Equatable {
  const BlacklistEntry({
    required this.id,
    required this.phoneNumber,
    this.label,
    this.reason = BlockReason.spam,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String phoneNumber; // E.164 normalisé, ex. +33612345678
  final String? label;      // libellé lisible, ex. "Spam assurance"
  final BlockReason reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, phoneNumber, label, reason, createdAt, updatedAt];

  // ─── DB serialization ───────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': id,
        'phone_number': phoneNumber,
        'label': label,
        'reason': reason.name,
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory BlacklistEntry.fromMap(Map<String, dynamic> map) => BlacklistEntry(
        id: map['id'] as String,
        phoneNumber: map['phone_number'] as String,
        label: map['label'] as String?,
        reason: BlockReason.values.firstWhere(
          (r) => r.name == map['reason'],
          orElse: () => BlockReason.spam,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      );

  // Sentinel for distinguishing "not passed" from explicit null in label.
  static const _absent = Object();

  BlacklistEntry copyWith({
    Object? label = _absent,
    BlockReason? reason,
    DateTime? updatedAt,
  }) =>
      BlacklistEntry(
        id: id,
        phoneNumber: phoneNumber,
        label: label == _absent ? this.label : label as String?,
        reason: reason ?? this.reason,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
