import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/messages/data/models/captured_message.dart';
import 'package:harmony/features/messages/data/models/message_rule.dart';
import 'package:harmony/features/messages/data/repositories/mock_messages_repository.dart';
import 'package:harmony/features/messages/logic/messages_cubit.dart';
import 'package:harmony/features/messages/presentation/screens/messages_filter_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';

Widget _wrap(Widget child, {MessagesCubit? cubit}) {
  final c = cubit ??
      MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: true),
      );
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('fr'),
    home: BlocProvider.value(
      value: c,
      child: child,
    ),
  );
}

void main() {
  group('MessagesFilterScreen', () {
    testWidgets('affiche le CircularProgressIndicator pendant le chargement', (tester) async {
      final cubit = MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: true),
      );
      await tester.pumpWidget(_wrap(const MessagesFilterScreen(), cubit: cubit));
      // État initial = MessagesInitial → loading spinner
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('affiche les messages après chargement', (tester) async {
      final cubit = MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: true),
      );
      await tester.pumpWidget(_wrap(const MessagesFilterScreen(), cubit: cubit));
      await tester.pumpAndSettle();

      // MockMessagesRepository a 5 messages par défaut
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('affiche le bouton FAB quand l\'état est Loaded', (tester) async {
      final cubit = MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: true),
      );
      await tester.pumpWidget(_wrap(const MessagesFilterScreen(), cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('affiche le statut listener désactivé quand listenerEnabled=false', (tester) async {
      final cubit = MessagesCubit(
        repository: MockMessagesRepository(listenerEnabled: false),
      );
      await tester.pumpWidget(_wrap(const MessagesFilterScreen(), cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.textContaining('notifications'), findsWidgets);
    });
  });

  group('MockMessagesRepository', () {
    test('retourne 5 messages par défaut', () async {
      final repo = MockMessagesRepository();
      final messages = await repo.getAllMessages();
      expect(messages.length, equals(5));
    });

    test('isListenerEnabled retourne la valeur passée', () async {
      expect(await MockMessagesRepository(listenerEnabled: true).isListenerEnabled(), isTrue);
      expect(await MockMessagesRepository(listenerEnabled: false).isListenerEnabled(), isFalse);
    });

    test('addRule ajoute correctement une règle', () async {
      final repo = MockMessagesRepository();
      await repo.addRule(
        const MessageRule(
          id: 'test-id',
          ruleType: RuleType.keyword,
          value: 'spam',
          action: RuleAction.block,
          sources: [],
        ),
      );
      final rules = await repo.getRules();
      expect(rules.length, equals(1));
      expect(rules.first.value, equals('spam'));
    });

    test('deleteRule supprime la règle', () async {
      final repo = MockMessagesRepository(
        rules: [
          const MessageRule(
            id: 'del-id',
            ruleType: RuleType.keyword,
            value: 'delete-me',
            action: RuleAction.block,
            sources: [],
          ),
        ],
      );
      await repo.deleteRule('del-id');
      expect(await repo.getRules(), isEmpty);
    });

    test('readRecentSms ne retourne que les SMS', () async {
      final repo = MockMessagesRepository();
      final sms = await repo.readRecentSms();
      expect(sms.every((m) => m.source == MessageSource.sms), isTrue);
    });

    test('getInterceptedNotifications ne retourne pas les SMS', () async {
      final repo = MockMessagesRepository();
      final notifs = await repo.getInterceptedNotifications();
      expect(notifs.every((m) => m.source != MessageSource.sms), isTrue);
    });
  });
}
