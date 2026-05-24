import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/call_filter/domain/outgoing_call_detector.dart';
import 'package:harmony/features/call_filter/presentation/widgets/outgoing_call_alert_dialog.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.darkTheme,
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('fr')],
      home: Scaffold(body: child),
    );

Widget _buildTrigger({
  required OutgoingCallRisk risk,
  required String number,
  void Function(bool)? onResult,
}) =>
    Builder(
      builder: (ctx) => ElevatedButton(
        onPressed: () async {
          final r = await showOutgoingCallAlertDialog(
            context: ctx,
            phoneNumber: number,
            risk: risk,
          );
          onResult?.call(r);
        },
        child: const Text('Open'),
      ),
    );

void main() {
  const dangerRisk = OutgoingCallRisk(
    level: OutgoingCallRiskLevel.danger,
    reason: 'Numéro surtaxé (0899…)',
    estimatedCostPerMinute: 1.50,
  );

  const warningRisk = OutgoingCallRisk(
    level: OutgoingCallRiskLevel.warning,
    reason: 'Numéro international (coûts potentiels)',
  );

  group('OutgoingCallAlertDialog', () {
    testWidgets('affiche le titre et le numéro', (tester) async {
      await tester.pumpWidget(
        _wrap(_buildTrigger(risk: dangerRisk, number: '0899123456')),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('0899123456'), findsOneWidget);
      expect(find.text('Appel potentiellement surtaxé'), findsOneWidget);
    });

    testWidgets('affiche le coût estimé pour un numéro danger', (tester) async {
      await tester.pumpWidget(
        _wrap(_buildTrigger(risk: dangerRisk, number: '0899123456')),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('1.50'), findsOneWidget);
    });

    testWidgets('bouton Annuler retourne false', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _wrap(
          _buildTrigger(
            risk: dangerRisk,
            number: '0899123456',
            onResult: (r) => result = r,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(result, false);
    });

    testWidgets('bouton Continuer retourne true', (tester) async {
      bool? result;
      await tester.pumpWidget(
        _wrap(
          _buildTrigger(
            risk: dangerRisk,
            number: '0899123456',
            onResult: (r) => result = r,
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Continuer l'appel"));
      await tester.pumpAndSettle();
      expect(result, true);
    });

    testWidgets('pas de coût estimé pour un numéro warning', (tester) async {
      await tester.pumpWidget(
        _wrap(_buildTrigger(risk: warningRisk, number: '+447911123456')),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.textContaining('€/min'), findsNothing);
    });
  });
}
