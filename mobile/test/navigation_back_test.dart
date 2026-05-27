import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/core/router/route_names.dart';
import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';
import 'package:harmony/features/call_filter/data/repositories/i_blacklist_repository.dart';
import 'package:harmony/features/call_filter/logic/blacklist_cubit.dart';
import 'package:harmony/features/call_filter/presentation/screens/call_filter_screen.dart';
import 'package:harmony/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

class _EmptyBlacklistRepo implements IBlacklistRepository {
  @override Future<List<BlacklistEntry>> getAll() async => [];
  @override Future<BlacklistEntry?> getById(String id) async => null;
  @override Future<BlacklistEntry?> getByNumber(String phoneNumber) async => null;
  @override Future<void> add(BlacklistEntry entry) async {}
  @override Future<void> update(BlacklistEntry entry) async {}
  @override Future<void> delete(String id) async {}
  @override Future<void> clear() async {}
  @override Future<List<BlacklistEntry>> search(String query) async => [];
  @override Future<void> syncToNative() async {}
}

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

Widget _buildTestApp() => BlocProvider(
      create: (_) => BlacklistCubit(_EmptyBlacklistRepo()),
      child: MaterialApp.router(
        theme: AppTheme.darkTheme,
        routerConfig: _testRouter(),
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('fr')],
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.dragUntilVisible(
    finder,
    find.byType(ListView),
    const Offset(0, -100),
  );
  await tester.pump();
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

      await _scrollTo(tester, find.text('Sécurité'));
      await tester.tap(find.text('Sécurité'));
      await _settle(tester);

      expect(find.byType(CallFilterScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('tap retour depuis CallFilterScreen revient au Dashboard', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pump();

      await _scrollTo(tester, find.text('Sécurité'));
      await tester.tap(find.text('Sécurité'));
      await _settle(tester);
      expect(find.byType(CallFilterScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await _settle(tester);

      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}
