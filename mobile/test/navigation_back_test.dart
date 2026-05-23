import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/core/router/route_names.dart';
import 'package:harmony/features/call_filter/presentation/screens/call_filter_screen.dart';
import 'package:harmony/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

GoRouter _testRouter() => GoRouter(
      initialLocation: RouteNames.dashboard,
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.security,
          builder: (_, __) => const CallFilterScreen(),
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

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  group('Navigation — bouton retour universel', () {
    testWidgets('Dashboard n\'a pas de bouton retour', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });

    testWidgets('CallFilterScreen affiche le bouton retour', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Sécurité'));
      await _settle(tester);

      expect(find.byType(CallFilterScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('tap retour depuis CallFilterScreen revient au Dashboard', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await tester.tap(find.text('Sécurité'));
      await _settle(tester);
      expect(find.byType(CallFilterScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await _settle(tester);

      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}
