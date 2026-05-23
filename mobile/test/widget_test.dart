import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  testWidgets('HarmonyApp démarre et affiche le titre Harmony', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HarmonyApp());
    // pump() plutôt que pumpAndSettle() car HarmonyStatusDot a une animation infinie
    await tester.pump();

    // Le titre "Harmony" doit apparaître dans l'AppBar du Dashboard
    expect(find.text('Harmony'), findsWidgets);
  });
}
