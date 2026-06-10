enum ListMode {
  blacklist,
  whitelist;

  static ListMode fromString(String v) =>
      v == 'whitelist' ? ListMode.whitelist : ListMode.blacklist;
}

class CallFilterRule {
  const CallFilterRule({
    required this.id,
    required this.childId,
    required this.phoneNumber,
    required this.listType,
    this.label,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String childId;
  final String phoneNumber;
  final ListMode listType;
  final String? label;
  final String createdBy;
  final DateTime createdAt;

  factory CallFilterRule.fromJson(Map<String, dynamic> j) => CallFilterRule(
        id: j['id'] as String,
        childId: j['child_id'] as String,
        phoneNumber: j['phone_number'] as String,
        listType: ListMode.fromString(j['list_type'] as String),
        label: j['label'] as String?,
        createdBy: j['created_by'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class CallFilterSettings {
  const CallFilterSettings({
    required this.listMode,
    this.blockHourStart,
    this.blockHourEnd,
  });

  final ListMode listMode;
  final int? blockHourStart;
  final int? blockHourEnd;

  factory CallFilterSettings.fromJson(Map<String, dynamic> j) =>
      CallFilterSettings(
        listMode: ListMode.fromString(j['list_mode'] as String),
        blockHourStart: j['block_hour_start'] as int?,
        blockHourEnd: j['block_hour_end'] as int?,
      );

  static const CallFilterSettings defaults =
      CallFilterSettings(listMode: ListMode.blacklist);
}
