import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum EventCategory { sport, medical, professional, school, leisure, other }

class AgendaEvent extends Equatable {
  const AgendaEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.startDate,
    required this.endDate,
    this.location,
    this.recurrenceRule,
    this.reminderMinutesBefore = 30,
    this.important = false,
    this.googleEventId,
    this.familyMemberIds = const [],
    required this.color,
  });

  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final String? recurrenceRule;
  final int reminderMinutesBefore;
  final bool important;
  final String? googleEventId;
  final List<String> familyMemberIds;
  final Color color;

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.index,
        'start_date': startDate.millisecondsSinceEpoch,
        'end_date': endDate.millisecondsSinceEpoch,
        'location': location,
        'recurrence_rule': recurrenceRule,
        'reminder_minutes_before': reminderMinutesBefore,
        'important': important ? 1 : 0,
        'google_event_id': googleEventId,
        'family_member_ids': familyMemberIds.join(','),
        'color': color.toARGB32(),
      };

  factory AgendaEvent.fromMap(Map<String, dynamic> m) => AgendaEvent(
        id: m['id'] as String,
        title: m['title'] as String,
        description: (m['description'] as String?) ?? '',
        category: EventCategory.values[m['category'] as int],
        startDate: DateTime.fromMillisecondsSinceEpoch(m['start_date'] as int),
        endDate: DateTime.fromMillisecondsSinceEpoch(m['end_date'] as int),
        location: m['location'] as String?,
        recurrenceRule: m['recurrence_rule'] as String?,
        reminderMinutesBefore: (m['reminder_minutes_before'] as int?) ?? 30,
        important: (m['important'] as int? ?? 0) == 1,
        googleEventId: m['google_event_id'] as String?,
        familyMemberIds: ((m['family_member_ids'] as String?) ?? '')
            .split(',')
            .where((s) => s.isNotEmpty)
            .toList(),
        color: Color(m['color'] as int),
      );

  AgendaEvent copyWith({
    String? title,
    String? description,
    EventCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? recurrenceRule,
    int? reminderMinutesBefore,
    bool? important,
    String? googleEventId,
    List<String>? familyMemberIds,
    Color? color,
  }) =>
      AgendaEvent(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        location: location ?? this.location,
        recurrenceRule: recurrenceRule ?? this.recurrenceRule,
        reminderMinutesBefore:
            reminderMinutesBefore ?? this.reminderMinutesBefore,
        important: important ?? this.important,
        googleEventId: googleEventId ?? this.googleEventId,
        familyMemberIds: familyMemberIds ?? this.familyMemberIds,
        color: color ?? this.color,
      );
}

/// Couleur par défaut pour chaque catégorie.
Color categoryColor(EventCategory cat) => switch (cat) {
      EventCategory.sport => const Color(0xFF10B981),
      EventCategory.medical => const Color(0xFFEF4444),
      EventCategory.professional => const Color(0xFF3B82F6),
      EventCategory.school => const Color(0xFF8B5CF6),
      EventCategory.leisure => const Color(0xFFF59E0B),
      EventCategory.other => const Color(0xFF64748B),
    };
