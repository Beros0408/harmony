import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/l10n/app_localizations.dart';

Future<AppLocalizations> _loadL10n(WidgetTester tester, String lang) async {
  late AppLocalizations result;
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (ctx) {
          result = AppLocalizations.of(ctx)!;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pump();
  return result;
}

void main() {
  group('L10n — toutes les locales', () {
    for (final lang in ['fr', 'en', 'es', 'pt', 'it']) {
      testWidgets('locale $lang se charge sans erreur', (tester) async {
        final l10n = await _loadL10n(tester, lang);
        expect(l10n.appName, 'Harmony');
        expect(l10n.navBack, isNotEmpty);
        expect(l10n.settingsTitle, isNotEmpty);
        expect(l10n.securityScreenTitle, isNotEmpty);
        expect(l10n.familyScreenTitle, isNotEmpty);
        expect(l10n.fitnessScreenTitle, isNotEmpty);
        expect(l10n.agendaScreenTitle, isNotEmpty);
      });
    }

    testWidgets('navBack traduit dans chaque locale', (tester) async {
      final expected = {
        'fr': 'Retour',
        'en': 'Back',
        'es': 'Volver',
        'pt': 'Voltar',
        'it': 'Indietro',
      };
      for (final entry in expected.entries) {
        final l10n = await _loadL10n(tester, entry.key);
        expect(l10n.navBack, entry.value, reason: 'locale=${entry.key}');
      }
    });

    testWidgets('settingsTitle traduit dans chaque locale', (tester) async {
      final expected = {
        'fr': 'Paramètres',
        'en': 'Settings',
        'es': 'Configuración',
        'pt': 'Definições',
        'it': 'Impostazioni',
      };
      for (final entry in expected.entries) {
        final l10n = await _loadL10n(tester, entry.key);
        expect(l10n.settingsTitle, entry.value, reason: 'locale=${entry.key}');
      }
    });
  });
}
