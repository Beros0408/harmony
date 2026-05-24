import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/core/router/route_names.dart';
import 'package:harmony/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

GoRouter _testRouter() => GoRouter(
      initialLocation: RouteNames.contacts,
      routes: [
        GoRoute(
          path: RouteNames.contacts,
          builder: (_, __) => const ContactsScreen(),
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

  group('ContactsScreen', () {
    testWidgets('affiche le titre "Contacts"', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('Contacts'), findsWidgets);
    });

    testWidgets('affiche la section LISTE BLANCHE', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('LISTE BLANCHE'), findsOneWidget);
    });

    testWidgets('affiche la section LISTE NOIRE', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('LISTE NOIRE'), findsOneWidget);
    });

    testWidgets('affiche les contacts de la liste blanche', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('Alice Dupont'), findsOneWidget);
      expect(find.text('Bob Martin'), findsOneWidget);
    });

    testWidgets('affiche les contacts de la liste noire', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('Spam Téléphonie'), findsOneWidget);
    });

    testWidgets('barre de recherche est présente', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('bouton "Ajouter un contact" est présent', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('Ajouter un contact'), findsOneWidget);
    });
  });
}
