import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/core/router/route_names.dart';
import 'package:harmony/features/voicemail/presentation/screens/voicemail_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

GoRouter _testRouter() => GoRouter(
      initialLocation: RouteNames.voicemail,
      routes: [
        GoRoute(
          path: RouteNames.voicemail,
          builder: (_, __) => const VoicemailScreen(showPushOnLoad: false),
        ),
      ],
    );

Widget _buildTestApp() => MaterialApp.router(
      theme: AppTheme.darkTheme,
      routerConfig: _testRouter(),
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('fr')],
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  group('VoicemailScreen', () {
    testWidgets('affiche le titre "Messagerie vocale"', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('Messagerie vocale'), findsWidgets);
    });

    testWidgets('affiche les 4 messages mock', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('Alice Dupont'), findsOneWidget);
      expect(find.text('Bob Martin'), findsOneWidget);
      expect(find.text('Cabinet Médical'), findsOneWidget);
      expect(find.text('Numéro inconnu'), findsOneWidget);
    });

    testWidgets('affiche le badge Urgent sur le premier message', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('Urgent'), findsWidgets);
    });

    testWidgets('la note mock est affichée en bas', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(
        find.textContaining('Transcriptions simulées'),
        findsOneWidget,
      );
    });
  });
}
