import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/shared/widgets/harmony_badge.dart';
import 'package:harmony/core/constants/app_colors.dart';
import 'package:harmony/shared/theme/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Center(child: child)),
    );

/// Trouve le Container racine du HarmonyBadge (descendant direct)
Container _badgeContainer(WidgetTester tester) {
  return tester.widget<Container>(
    find
        .descendant(
          of: find.byType(HarmonyBadge),
          matching: find.byType(Container),
        )
        .first,
  );
}

void main() {
  group('HarmonyBadge', () {
    testWidgets('affiche le label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HarmonyBadge(
            label: 'Actif',
            variant: HarmonyBadgeVariant.success,
          ),
        ),
      );
      expect(find.text('Actif'), findsOneWidget);
    });

    testWidgets('variant success utilise accentGreen', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HarmonyBadge(
            label: 'OK',
            variant: HarmonyBadgeVariant.success,
          ),
        ),
      );
      final decoration = _badgeContainer(tester).decoration as BoxDecoration;
      expect(decoration.color, AppColors.accentGreen.withValues(alpha: 0.12));
    });

    testWidgets('variant warning utilise accentAmber', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HarmonyBadge(
            label: 'Attention',
            variant: HarmonyBadgeVariant.warning,
          ),
        ),
      );
      final decoration = _badgeContainer(tester).decoration as BoxDecoration;
      expect(decoration.color, AppColors.accentAmber.withValues(alpha: 0.12));
    });

    testWidgets('variant danger utilise accentRed', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HarmonyBadge(
            label: 'Erreur',
            variant: HarmonyBadgeVariant.danger,
          ),
        ),
      );
      final decoration = _badgeContainer(tester).decoration as BoxDecoration;
      expect(decoration.color, AppColors.accentRed.withValues(alpha: 0.12));
    });

    testWidgets('variant info utilise accentBlue', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HarmonyBadge(
            label: 'Info',
            variant: HarmonyBadgeVariant.info,
          ),
        ),
      );
      final decoration = _badgeContainer(tester).decoration as BoxDecoration;
      expect(decoration.color, AppColors.accentBlue.withValues(alpha: 0.12));
    });

    testWidgets('affiche une icône quand fournie', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const HarmonyBadge(
            label: 'Avec icône',
            variant: HarmonyBadgeVariant.success,
            icon: Icons.check,
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
