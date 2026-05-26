import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/messages/data/models/captured_message.dart';
import 'package:harmony/features/messages/data/models/message_rule.dart';

void main() {
  group('MessageSource', () {
    test('fromPackage retourne WhatsApp pour com.whatsapp', () {
      expect(
        MessageSource.fromPackage('com.whatsapp'),
        MessageSource.whatsApp,
      );
    });

    test('fromPackage retourne Signal pour org.thoughtcrime.securesms', () {
      expect(
        MessageSource.fromPackage('org.thoughtcrime.securesms'),
        MessageSource.signal,
      );
    });

    test('fromPackage retourne unknown pour un package inconnu', () {
      expect(
        MessageSource.fromPackage('com.unknown.app'),
        MessageSource.unknown,
      );
    });

    test('displayName est non vide pour toutes les sources', () {
      for (final source in MessageSource.values) {
        expect(source.displayName, isNotEmpty);
      }
    });
  });

  group('TimeRange', () {
    test('containsHour — plage normale 9h-18h', () {
      const range = TimeRange(startHour: 9, endHour: 18);
      expect(range.containsHour(9), isTrue);
      expect(range.containsHour(12), isTrue);
      expect(range.containsHour(17), isTrue);
      expect(range.containsHour(18), isFalse);
      expect(range.containsHour(8), isFalse);
    });

    test('containsHour — plage traversant minuit 22h-7h', () {
      const range = TimeRange(startHour: 22, endHour: 7);
      expect(range.containsHour(22), isTrue);
      expect(range.containsHour(0), isTrue);
      expect(range.containsHour(6), isTrue);
      expect(range.containsHour(7), isFalse);
      expect(range.containsHour(12), isFalse);
    });
  });

  group('MessageRule.matches', () {
    final baseMessage = CapturedMessage(
      id: '1',
      sender: '+33612345678',
      content: 'Achetez maintenant — promo exclusive !',
      timestamp: DateTime(2026, 5, 26, 14, 0),
      source: MessageSource.sms,
    );

    test('règle keyword — match si le contenu contient le mot-clé', () {
      final rule = MessageRule(
        id: 'r1',
        ruleType: RuleType.keyword,
        value: 'promo',
        action: RuleAction.block,
        sources: const [],
      );
      expect(rule.matches(baseMessage), isTrue);
    });

    test('règle keyword — no match si le mot-clé est absent', () {
      final rule = MessageRule(
        id: 'r2',
        ruleType: RuleType.keyword,
        value: 'bitcoin',
        action: RuleAction.block,
        sources: const [],
      );
      expect(rule.matches(baseMessage), isFalse);
    });

    test('règle keyword — case-insensitive', () {
      final rule = MessageRule(
        id: 'r3',
        ruleType: RuleType.keyword,
        value: 'PROMO',
        action: RuleAction.block,
        sources: const [],
      );
      expect(rule.matches(baseMessage), isTrue);
    });

    test('règle contact — match si le sender contient la valeur', () {
      final rule = MessageRule(
        id: 'r4',
        ruleType: RuleType.contact,
        value: '+33612345678',
        action: RuleAction.block,
        sources: const [],
      );
      expect(rule.matches(baseMessage), isTrue);
    });

    test('règle source filtrée — no match si la source ne correspond pas', () {
      final rule = MessageRule(
        id: 'r5',
        ruleType: RuleType.keyword,
        value: 'promo',
        action: RuleAction.block,
        sources: const [MessageSource.whatsApp],
      );
      // Message SMS ne matche pas une règle WhatsApp uniquement
      expect(rule.matches(baseMessage), isFalse);
    });

    test('règle désactivée — ne matche jamais', () {
      final rule = MessageRule(
        id: 'r6',
        ruleType: RuleType.keyword,
        value: 'promo',
        action: RuleAction.block,
        sources: const [],
        isEnabled: false,
      );
      expect(rule.matches(baseMessage), isFalse);
    });

    test('règle schedule — match si l\'heure du message est dans la plage', () {
      final rule = MessageRule(
        id: 'r7',
        ruleType: RuleType.schedule,
        value: '',
        action: RuleAction.block,
        sources: const [],
        schedule: const TimeRange(startHour: 12, endHour: 16),
      );
      // Message à 14h → dans la plage 12-16
      expect(rule.matches(baseMessage), isTrue);
    });
  });

  group('CapturedMessage', () {
    test('copyWith préserve les champs non modifiés', () {
      final original = CapturedMessage(
        id: 'abc',
        sender: 'Alice',
        content: 'Hello',
        timestamp: DateTime(2026),
        source: MessageSource.sms,
      );
      final modified = original.copyWith(isBlocked: true, blockReason: 'test');
      expect(modified.id, 'abc');
      expect(modified.sender, 'Alice');
      expect(modified.isBlocked, isTrue);
      expect(modified.blockReason, 'test');
    });

    test('fromMap reconstruit correctement un message', () {
      final map = {
        'id': 'id1',
        'sender': '+336',
        'content': 'Bonjour',
        'timestamp': 1000000,
        'packageName': 'com.whatsapp',
        'isBlocked': false,
      };
      final msg = CapturedMessage.fromMap(map);
      expect(msg.id, 'id1');
      expect(msg.sender, '+336');
      expect(msg.source, MessageSource.whatsApp);
      expect(msg.isBlocked, isFalse);
    });
  });
}
