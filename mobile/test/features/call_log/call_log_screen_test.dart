import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/core/router/route_names.dart';
import 'package:harmony/features/call_log/presentation/screens/call_log_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

const _channel = MethodChannel('com.harmony.app/call_filter');

GoRouter _testRouter() => GoRouter(
      initialLocation: RouteNames.callLog,
      routes: [
        GoRoute(
          path: RouteNames.callLog,
          builder: (_, __) => const CallLogScreen(),
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
    // Mock le MethodChannel pour renvoyer des données vides
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      return switch (call.method) {
        'getBlockedCalls' => <Map<String, dynamic>>[],
        'isDefaultScreeningApp' => false,
        _ => null,
      };
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  group('CallLogScreen', () {
    testWidgets('affiche le titre du journal', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text('Journal des blocages'), findsWidgets);
    });

    testWidgets('affiche l\'état vide quand aucun appel bloqué', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Aucun appel bloqué'), findsOneWidget);
    });

    testWidgets('affiche les 3 filtres de période', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();
      expect(find.text("Aujourd'hui"), findsOneWidget);
      expect(find.text('Cette semaine'), findsOneWidget);
      expect(find.text('Tout'), findsOneWidget);
    });
  });
}
