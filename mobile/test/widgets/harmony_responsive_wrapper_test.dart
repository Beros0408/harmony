import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/shared/widgets/harmony_responsive_wrapper.dart';

// Helper pour tester le widget en isolation sans MaterialApp internals
Widget _wrap({
  required double width,
  required Widget child,
  double maxWidth = 480,
}) {
  return MediaQuery(
    data: MediaQueryData(size: Size(width, 844)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: ThemeData.dark(),
        child: HarmonyResponsiveWrapper(
          maxWidth: maxWidth,
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('HarmonyResponsiveWrapper', () {
    testWidgets('sur mobile (largeur <= 480px) ne wrap pas le contenu',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          width: 390,
          child: Container(key: const Key('content')),
        ),
      );

      expect(find.byKey(const Key('content')), findsOneWidget);
      // Sur mobile, le wrapper ne doit PAS ajouter ColoredBox ni Center
      expect(find.byType(ColoredBox), findsNothing);
      expect(find.byType(Center), findsNothing);
    });

    testWidgets('sur desktop (largeur > 480px) centre avec ConstrainedBox',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          width: 1920,
          child: Container(key: const Key('content')),
        ),
      );

      expect(find.byKey(const Key('content')), findsOneWidget);
      // Sur desktop, ColoredBox, Center et ConstrainedBox sont ajoutés par le wrapper
      expect(find.byType(ColoredBox), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    testWidgets('respecte maxWidth personnalisée', (tester) async {
      await tester.pumpWidget(
        _wrap(
          width: 1920,
          maxWidth: 600,
          child: Container(key: const Key('content')),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox).first,
      );
      expect(constrainedBox.constraints.maxWidth, 600);
    });
  });
}
