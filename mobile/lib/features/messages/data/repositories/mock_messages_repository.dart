import '../../domain/i_messages_repository.dart';
import '../models/captured_message.dart';
import '../models/message_rule.dart';

/// Implémentation de test de IMessagesRepository.
/// Retourne des données hardcodées — aucune dépendance au MethodChannel.
class MockMessagesRepository implements IMessagesRepository {
  MockMessagesRepository({
    bool listenerEnabled = true,
    List<CapturedMessage>? messages,
    List<MessageRule>? rules,
  })  : _listenerEnabled = listenerEnabled,
        _messages = messages ?? _defaultMessages(),
        _rules = rules != null ? List.of(rules) : [];

  bool _listenerEnabled;
  final List<CapturedMessage> _messages;
  final List<MessageRule> _rules;

  static List<CapturedMessage> _defaultMessages() => [
        CapturedMessage(
          id: '1',
          sender: '+33612345678',
          content: 'Salut ! Tu es disponible ce soir ?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          source: MessageSource.sms,
        ),
        CapturedMessage(
          id: '2',
          sender: 'Alice Martin',
          content: 'Réunion repoussée à 15h, tu peux prévenir l\'équipe ?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          source: MessageSource.whatsApp,
        ),
        CapturedMessage(
          id: '3',
          sender: 'BON PLAN',
          content: 'Votre commande n°12345 a été expédiée.',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          source: MessageSource.sms,
          isBlocked: true,
          blockReason: 'Mot-clé: BON PLAN',
        ),
        CapturedMessage(
          id: '4',
          sender: 'Bob Dupont',
          content: 'Je t\'envoie les fichiers via Signal.',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          source: MessageSource.signal,
        ),
        CapturedMessage(
          id: '5',
          sender: 'Groupe Famille',
          content: 'Dimanche 12h chez mamie, confirme ta présence !',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          source: MessageSource.whatsApp,
        ),
      ];

  @override
  Future<bool> isListenerEnabled() async => _listenerEnabled;

  @override
  Future<void> requestListenerAccess() async {
    _listenerEnabled = true;
  }

  // Permission SMS toujours accordée en mock (tests unitaires).
  @override
  Future<bool> hasSmsPermission() async => true;

  @override
  Future<bool> requestSmsPermission() async => true;

  @override
  Future<List<CapturedMessage>> readRecentSms({int limit = 50}) async =>
      _messages.where((m) => m.source == MessageSource.sms).take(limit).toList();

  @override
  Future<List<CapturedMessage>> getInterceptedNotifications() async =>
      _messages.where((m) => m.source != MessageSource.sms).toList();

  @override
  Future<List<CapturedMessage>> getAllMessages({int limit = 100}) async {
    final all = List.of(_messages)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all.take(limit).toList();
  }

  @override
  Future<List<MessageRule>> getRules() async => List.unmodifiable(_rules);

  @override
  Future<void> addRule(MessageRule rule) async => _rules.add(rule);

  @override
  Future<void> updateRule(MessageRule rule) async {
    final idx = _rules.indexWhere((r) => r.id == rule.id);
    if (idx >= 0) _rules[idx] = rule;
  }

  @override
  Future<void> deleteRule(String id) async =>
      _rules.removeWhere((r) => r.id == id);
}
