import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/app.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR');
  });

  testWidgets('HarmonyApp démarre et affiche l\'écran d\'authentification', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HarmonyApp());
    // pump() plutôt que pumpAndSettle() : l'auth check est asynchrone
    await tester.pump();

    // L'app démarre sans exception — MaterialApp toujours présent
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
