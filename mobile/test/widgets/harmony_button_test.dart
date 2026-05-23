import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/shared/widgets/harmony_button.dart';
import 'package:harmony/core/constants/app_colors.dart';
import 'package:harmony/shared/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('HarmonyButton', () {
    testWidgets('affiche le label correctement', (tester) async {
      await tester.pumpWidget(
        _wrap(HarmonyButton(label: 'Mon bouton', onPressed: () {})),
      );
      expect(find.text('Mon bouton'), findsOneWidget);
    });

    testWidgets('déclenche onPressed au tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(HarmonyButton(label: 'Tap moi', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(HarmonyButton));
      expect(tapped, isTrue);
    });

    testWidgets('état loading affiche CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HarmonyButton(
            label: 'Chargement',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // En mode loading, le label ne doit pas être visible
      expect(find.text('Chargement'), findsNothing);
    });

    testWidgets('variant primary utilise accentBlue', (tester) async {
      await tester.pumpWidget(
        _wrap(
          HarmonyButton(
            label: 'Primary',
            onPressed: () {},
          ),
        ),
      );
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.accentBlue);
    });

    testWidgets('isDisabled empêche le tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          HarmonyButton(
            label: 'Désactivé',
            onPressed: () => tapped = true,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(HarmonyButton));
      expect(tapped, isFalse);
    });
  });
}
