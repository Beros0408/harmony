import 'dart:convert';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/messages_service.dart';
import '../../domain/i_messages_repository.dart';
import '../models/captured_message.dart';
import '../models/message_rule.dart';

/// Implémentation production de IMessagesRepository.
/// Utilise MessagesService (MethodChannel) pour les SMS et les notifications.
/// Les règles de filtrage sont persistées via SQLCipher (table message_rules).
class NativeMessagesRepository implements IMessagesRepository {
  NativeMessagesRepository({MessagesService? service})
      : _service = service ?? MessagesService.instance;

  final MessagesService _service;

  static final NativeMessagesRepository instance = NativeMessagesRepository();

  // Cache en mémoire chargé depuis SQLCipher au démarrage
  List<MessageRule> _rules = [];
  bool _rulesLoaded = false;

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

  @override
  Future<bool> hasSmsPermission() => _service.hasSmsPermission();

  @override
  Future<bool> requestSmsPermission() => _service.requestSmsPermission();

  // ─── Messages ──────────────────────────────────────────────────────────────

  @override
  Future<List<CapturedMessage>> readRecentSms({int limit = 50}) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.readRecentSms(limit=$limit)');
    try {
      await _ensureRulesLoaded();
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
      await _ensureRulesLoaded();
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

  Future<void> _ensureRulesLoaded() async {
    if (_rulesLoaded) return;
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository._ensureRulesLoaded() — chargement SQLCipher');
    final db = await DatabaseHelper.db;
    final rows = await db.query('message_rules', orderBy: 'created_at ASC');
    _rules = rows.map(_ruleFromMap).toList();
    _rulesLoaded = true;
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] _ensureRulesLoaded → ${_rules.length} règles');
  }

  @override
  Future<List<MessageRule>> getRules() async {
    await _ensureRulesLoaded();
    return List.unmodifiable(_rules);
  }

  @override
  Future<void> addRule(MessageRule rule) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.addRule(${rule.ruleType.name} "${rule.value}")');
    await _ensureRulesLoaded();
    final db = await DatabaseHelper.db;
    await db.insert('message_rules', _ruleToMap(rule));
    _rules.add(rule);
  }

  @override
  Future<void> updateRule(MessageRule rule) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.updateRule(${rule.id})');
    await _ensureRulesLoaded();
    final db = await DatabaseHelper.db;
    await db.update(
      'message_rules',
      _ruleToMap(rule),
      where: 'id = ?',
      whereArgs: [rule.id],
    );
    final idx = _rules.indexWhere((r) => r.id == rule.id);
    if (idx >= 0) _rules[idx] = rule;
  }

  @override
  Future<void> deleteRule(String id) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] NativeMessagesRepository.deleteRule($id)');
    await _ensureRulesLoaded();
    final db = await DatabaseHelper.db;
    await db.delete('message_rules', where: 'id = ?', whereArgs: [id]);
    _rules.removeWhere((r) => r.id == id);
  }

  // ─── Sérialisation SQLCipher ───────────────────────────────────────────────

  Map<String, dynamic> _ruleToMap(MessageRule rule) => {
        'id': rule.id,
        'type': rule.ruleType.name,
        'value': rule.value,
        'action': rule.action.name,
        'sources': jsonEncode(rule.sources.map((s) => s.name).toList()),
        'schedule_start_hour': rule.schedule?.startHour,
        'schedule_end_hour': rule.schedule?.endHour,
        'is_active': rule.isEnabled ? 1 : 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

  MessageRule _ruleFromMap(Map<String, dynamic> row) {
    final sourcesJson = row['sources'] as String? ?? '[]';
    final sourceNames = (jsonDecode(sourcesJson) as List).cast<String>();
    final sources = sourceNames
        .map((n) => MessageSource.values.firstWhere(
              (s) => s.name == n,
              orElse: () => MessageSource.sms,
            ))
        .toList();

    TimeRange? schedule;
    final startHour = row['schedule_start_hour'] as int?;
    final endHour = row['schedule_end_hour'] as int?;
    if (startHour != null && endHour != null) {
      schedule = TimeRange(startHour: startHour, endHour: endHour);
    }

    return MessageRule(
      id: row['id'] as String,
      ruleType: RuleType.values.firstWhere((t) => t.name == row['type']),
      value: row['value'] as String? ?? '',
      action: RuleAction.values.firstWhere((a) => a.name == row['action']),
      sources: sources,
      schedule: schedule,
      isEnabled: (row['is_active'] as int? ?? 1) == 1,
    );
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
