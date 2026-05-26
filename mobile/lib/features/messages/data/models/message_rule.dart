import 'package:equatable/equatable.dart';
import 'captured_message.dart';

/// Type de condition d'une règle de filtrage.
enum RuleType {
  contact,
  keyword,
  schedule;

  String get displayName => switch (this) {
        RuleType.contact => 'Contact',
        RuleType.keyword => 'Mot-clé',
        RuleType.schedule => 'Plage horaire',
      };
}

/// Action à appliquer quand une règle correspond.
enum RuleAction {
  block,
  allow;

  String get displayName => switch (this) {
        RuleAction.block => 'Bloquer',
        RuleAction.allow => 'Autoriser',
      };
}

/// Plage horaire pour les règles de type schedule.
class TimeRange extends Equatable {
  const TimeRange({required this.startHour, required this.endHour});

  /// Heure de début (0-23).
  final int startHour;

  /// Heure de fin (0-23, exclusive).
  final int endHour;

  bool containsHour(int hour) {
    if (startHour <= endHour) {
      return hour >= startHour && hour < endHour;
    }
    // Plage qui traverse minuit (ex: 22h-7h)
    return hour >= startHour || hour < endHour;
  }

  @override
  List<Object?> get props => [startHour, endHour];
}

/// Règle de filtrage de message.
class MessageRule extends Equatable {
  const MessageRule({
    required this.id,
    required this.ruleType,
    required this.value,
    required this.action,
    required this.sources,
    this.schedule,
    this.isEnabled = true,
  });

  final String id;
  final RuleType ruleType;

  /// Valeur associée à la règle :
  /// - contact : numéro ou nom
  /// - keyword : mot ou expression
  /// - schedule : non utilisé (utiliser schedule)
  final String value;

  final RuleAction action;

  /// Sources auxquelles s'applique la règle (vide = toutes).
  final List<MessageSource> sources;

  /// Plage horaire pour ruleType == schedule.
  final TimeRange? schedule;

  final bool isEnabled;

  MessageRule copyWith({
    String? id,
    RuleType? ruleType,
    String? value,
    RuleAction? action,
    List<MessageSource>? sources,
    TimeRange? schedule,
    bool? isEnabled,
  }) =>
      MessageRule(
        id: id ?? this.id,
        ruleType: ruleType ?? this.ruleType,
        value: value ?? this.value,
        action: action ?? this.action,
        sources: sources ?? this.sources,
        schedule: schedule ?? this.schedule,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  /// Indique si ce message correspond à la règle.
  bool matches(CapturedMessage message) {
    if (!isEnabled) return false;
    if (sources.isNotEmpty && !sources.contains(message.source)) return false;

    switch (ruleType) {
      case RuleType.contact:
        return message.sender.contains(value);
      case RuleType.keyword:
        return message.content.toLowerCase().contains(value.toLowerCase());
      case RuleType.schedule:
        if (schedule == null) return false;
        return schedule!.containsHour(message.timestamp.hour);
    }
  }

  @override
  List<Object?> get props =>
      [id, ruleType, value, action, sources, schedule, isEnabled];
}
