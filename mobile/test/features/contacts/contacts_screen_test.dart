import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/contacts/data/models/native_contact.dart';
import 'package:harmony/features/contacts/data/repositories/mock_contacts_repository.dart';
import 'package:harmony/features/contacts/logic/contacts_cubit.dart';
import 'package:harmony/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

Widget _buildApp({required ContactsCubit cubit}) => BlocProvider.value(
      value: cubit,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('fr')],
        home: const ContactsScreen(),
      ),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  ContactsCubit _cubit({bool permissionGranted = true}) => ContactsCubit(
        repository: MockContactsRepository(permissionGranted: permissionGranted),
      );

  group('ContactsScreen — permission accordée', () {
    testWidgets('affiche le titre "Contacts"', (tester) async {
      final cubit = _cubit();
      await tester.pumpWidget(_buildApp(cubit: cubit));
      await tester.pump(); // trigger initState → cubit.load()
      await tester.pump(); // settle async load

      expect(find.text('Contacts'), findsWidgets);
    });

    testWidgets('affiche les contacts natifs après chargement', (tester) async {
      final cubit = _cubit();
      await tester.pumpWidget(_buildApp(cubit: cubit));
      await tester.pump();
      await tester.pump();

      expect(find.text('Alice Dupont'), findsOneWidget);
      expect(find.text('Bob Martin'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('ContactsScreen — permission refusée', () {
    testWidgets('affiche le HarmonyEmptyState avec CTA permission', (
      tester,
    ) async {
      final cubit = _cubit(permissionGranted: false);
      await tester.pumpWidget(_buildApp(cubit: cubit));
      await tester.pump();
      await tester.pump();

      expect(find.text('Accès aux contacts requis'), findsOneWidget);
      expect(find.text('Autoriser l\'accès aux contacts'), findsOneWidget);
    });

    testWidgets('CTA permission demande la permission et charge les contacts', (
      tester,
    ) async {
      final cubit = _cubit(permissionGranted: false);
      await tester.pumpWidget(_buildApp(cubit: cubit));
      await tester.pump();
      await tester.pump();

      // Tap the CTA button
      await tester.tap(find.text('Autoriser l\'accès aux contacts'));
      await tester.pump();
      await tester.pump();

      // After granting, contacts should load
      expect(find.text('Alice Dupont'), findsOneWidget);
    });
  });
}
