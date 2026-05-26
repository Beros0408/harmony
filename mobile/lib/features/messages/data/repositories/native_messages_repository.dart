import '../../../../core/services/messages_service.dart';
import '../../domain/i_messages_repository.dart';
import '../models/captured_message.dart';
import '../models/message_rule.dart';

/// Implémentation production de IMessagesRepository.
/// Utilise MessagesService (MethodChannel) pour les SMS et les notifications.
/// Les règles de filtrage sont stockées en mémoire (persistance SQLCipher au Sprint 7).
class NativeMessagesRepository implements IMessagesRepository {
  NativeMessagesRepository({MessagesService? service})
      : _service = service ?? MessagesService.instance;

  final MessagesService _service;

  static final NativeMessagesRepository instance = NativeMessagesRepository();

  // Règles en mémoire — remplacées par SQLCipher au Sprint 7
  final List<MessageRule> _rules = [];

  // ─── Listener ──────────────────────────────────────────────────────────────

  @override
  Future<bool> isListenerEnabled() async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.isListenerEnabled()');
    return _service.isListenerEnabled();
  }

  @override
  Future<void> requestListenerAccess() async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.requestListenerAccess()');
    return _service.requestAccess();
  }

  // ─── Messages ──────────────────────────────────────────────────────────────

  @override
  Future<List<CapturedMessage>> readRecentSms({int limit = 50}) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.readRecentSms(limit=$limit)');
    try {
      final messages = await _service.readRecentSms(limit: limit);
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] readRecentSms → ${messages.length} SMS');
      return _applyRules(messages);
    } catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] readRecentSms FAILED ($e) → liste vide');
      return [];
    }
  }

  @override
  Future<List<CapturedMessage>> getInterceptedNotifications() async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.getInterceptedNotifications()');
    try {
      final messages = await _service.getInterceptedNotifications();
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] getInterceptedNotifications → ${messages.length} notifications');
      return _applyRules(messages);
    } catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] getInterceptedNotifications FAILED ($e) → liste vide');
      return [];
    }
  }

  @override
  Future<List<CapturedMessage>> getAllMessages({int limit = 100}) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.getAllMessages(limit=$limit)');
    final sms = await readRecentSms(limit: limit ~/ 2);
    final notifs = await getInterceptedNotifications();

    final all = [...sms, ...notifs]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final result = all.take(limit).toList();
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] getAllMessages → ${result.length} messages (${sms.length} SMS + ${notifs.length} notifs)');
    return result;
  }

  // ─── Règles ────────────────────────────────────────────────────────────────

  @override
  Future<List<MessageRule>> getRules() async => List.unmodifiable(_rules);

  @override
  Future<void> addRule(MessageRule rule) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.addRule(${rule.ruleType.name} "${rule.value}")');
    _rules.add(rule);
  }

  @override
  Future<void> updateRule(MessageRule rule) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.updateRule(${rule.id})');
    final idx = _rules.indexWhere((r) => r.id == rule.id);
    if (idx >= 0) _rules[idx] = rule;
  }

  @override
  Future<void> deleteRule(String id) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.deleteRule($id)');
    _rules.removeWhere((r) => r.id == id);
  }

  // ─── Matching ──────────────────────────────────────────────────────────────

  /// Applique les règles actives à une liste de messages.
  /// Marque les messages bloqués avec isBlocked=true et blockReason.
  List<CapturedMessage> _applyRules(List<CapturedMessage> messages) {
    if (_rules.isEmpty) return messages;
    return messages.map((msg) {
      for (final rule in _rules) {
        if (!rule.matches(msg)) continue;
        if (rule.action == RuleAction.block) {
          return msg.copyWith(
            isBlocked: true,
            blockReason: '${rule.ruleType.displayName}: ${rule.value}',
          );
        }
        if (rule.action == RuleAction.allow) return msg;
      }
      return msg;
    }).toList();
  }
}
