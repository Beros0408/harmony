import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/messages/data/models/captured_message.dart';
import 'package:harmony/features/messages/data/models/message_rule.dart';
import 'package:harmony/features/messages/data/repositories/mock_messages_repository.dart';
import 'package:harmony/features/messages/logic/messages_cubit.dart';

void main() {
  group('MessagesCubit — load', () {
    blocTest<MessagesCubit, MessagesState>(
      'émet Loading puis Loaded quand le listener est activé',
      build: () => MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: true),
      ),
      act: (c) => c.load(),
      expect: () => [
        isA<MessagesLoading>(),
        isA<MessagesLoaded>().having(
          (s) => (s as MessagesLoaded).listenerEnabled,
          'listenerEnabled',
          isTrue,
        ),
      ],
    );

    blocTest<MessagesCubit, MessagesState>(
      'Loaded contient les messages du mock',
      build: () => MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: true),
      ),
      act: (c) => c.load(),
      expect: () => [
        isA<MessagesLoading>(),
        isA<MessagesLoaded>().having(
          (s) => (s as MessagesLoaded).messages.length,
          'messages.length',
          greaterThan(0),
        ),
      ],
    );

    blocTest<MessagesCubit, MessagesState>(
      'Loaded avec listener désactivé reste Loaded (listenerEnabled=false)',
      build: () => MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: false),
      ),
      act: (c) => c.load(),
      expect: () => [
        isA<MessagesLoading>(),
        isA<MessagesLoaded>().having(
          (s) => (s as MessagesLoaded).listenerEnabled,
          'listenerEnabled',
          isFalse,
        ),
      ],
    );
  });

  group('MessagesCubit — addRule', () {
    blocTest<MessagesCubit, MessagesState>(
      'addRule ajoute une règle et recharge',
      build: () => MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: true),
      ),
      act: (c) async {
        await c.load();
        await c.addRule(
          const MessageRule(
            id: '',
            ruleType: RuleType.keyword,
            value: 'spam',
            action: RuleAction.block,
            sources: [],
          ),
        );
      },
      expect: () => [
        isA<MessagesLoading>(),
        isA<MessagesLoaded>(),
        isA<MessagesLoading>(),
        isA<MessagesLoaded>().having(
          (s) => (s as MessagesLoaded).rules.length,
          'rules.length',
          equals(1),
        ),
      ],
    );
  });

  group('MessagesCubit — deleteRule', () {
    blocTest<MessagesCubit, MessagesState>(
      'deleteRule supprime la règle',
      build: () => MessagesCubit(
        repository: MockMessagesRepository(
          listenerEnabled: true,
          rules: [
            const MessageRule(
              id: 'rule-1',
              ruleType: RuleType.keyword,
              value: 'pub',
              action: RuleAction.block,
              sources: [],
            ),
          ],
        ),
      ),
      act: (c) async {
        await c.load();
        await c.deleteRule('rule-1');
      },
      expect: () => [
        isA<MessagesLoading>(),
        isA<MessagesLoaded>().having(
          (s) => (s as MessagesLoaded).rules.length,
          'rules.length après load',
          equals(1),
        ),
        isA<MessagesLoading>(),
        isA<MessagesLoaded>().having(
          (s) => (s as MessagesLoaded).rules.length,
          'rules.length après delete',
          equals(0),
        ),
      ],
    );
  });

  group('MessagesCubit — requestListenerAccess', () {
    blocTest<MessagesCubit, MessagesState>(
      'requestListenerAccess active le listener et recharge',
      build: () => MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: false),
      ),
      act: (c) => c.requestListenerAccess(),
      expect: () => [
        isA<MessagesLoading>(),
        isA<MessagesLoaded>().having(
          (s) => (s as MessagesLoaded).listenerEnabled,
          'listenerEnabled après activation',
          isTrue,
        ),
      ],
    );
  });

  group('MessagesLoaded — stats', () {
    test('blockedCount retourne le nombre de messages bloqués', () {
      final state = MessagesLoaded(
        messages: [
          CapturedMessage(
            id: '1',
            sender: 'A',
            content: 'ok',
            timestamp: DateTime.now(),
            source: MessageSource.sms,
            isBlocked: true,
          ),
          CapturedMessage(
            id: '2',
            sender: 'B',
            content: 'ok',
            timestamp: DateTime.now(),
            source: MessageSource.whatsApp,
            isBlocked: false,
          ),
        ],
        rules: const [],
        listenerEnabled: true,
      );
      expect(state.blockedCount, equals(1));
      expect(state.totalCount, equals(2));
    });
  });
}
