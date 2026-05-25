import 'package:equatable/equatable.dart';

enum TaskUrgency { low, medium, high }

enum TaskImportance { low, medium, high }

enum EisenhowerQuadrant {
  doFirst,   // urgent + important
  schedule,  // not urgent + important
  delegate,  // urgent + not important
  delete,    // not urgent + not important
}

class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.title,
    required this.urgency,
    required this.importance,
    this.deadline,
    this.completed = false,
    this.linkedEventId,
  });

  final String id;
  final String title;
  final TaskUrgency urgency;
  final TaskImportance importance;
  final DateTime? deadline;
  final bool completed;
  final String? linkedEventId;

  EisenhowerQuadrant get quadrant {
    final isUrgent = urgency != TaskUrgency.low;
    final isImportant = importance != TaskImportance.low;
    if (isUrgent && isImportant) return EisenhowerQuadrant.doFirst;
    if (!isUrgent && isImportant) return EisenhowerQuadrant.schedule;
    if (isUrgent && !isImportant) return EisenhowerQuadrant.delegate;
    return EisenhowerQuadrant.delete;
  }

  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'urgency': urgency.index,
        'importance': importance.index,
        'deadline': deadline?.millisecondsSinceEpoch,
        'completed': completed ? 1 : 0,
        'linked_event_id': linkedEventId,
      };

  factory TaskItem.fromMap(Map<String, dynamic> m) => TaskItem(
        id: m['id'] as String,
        title: m['title'] as String,
        urgency: TaskUrgency.values[m['urgency'] as int],
        importance: TaskImportance.values[m['importance'] as int],
        deadline: m['deadline'] != null
            ? DateTime.fromMillisecondsSinceEpoch(m['deadline'] as int)
            : null,
        completed: (m['completed'] as int? ?? 0) == 1,
        linkedEventId: m['linked_event_id'] as String?,
      );

  TaskItem copyWith({
    String? title,
    TaskUrgency? urgency,
    TaskImportance? importance,
    DateTime? deadline,
    bool? completed,
    String? linkedEventId,
  }) =>
      TaskItem(
        id: id,
        title: title ?? this.title,
        urgency: urgency ?? this.urgency,
        importance: importance ?? this.importance,
        deadline: deadline ?? this.deadline,
        completed: completed ?? this.completed,
        linkedEventId: linkedEventId ?? this.linkedEventId,
      );
}
