import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'features/call_filter/data/repositories/blacklist_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await BlacklistRepository.instance.init();

  // Push blacklist snapshot to Kotlin CallDecisionEngine at startup.
  // Runs after the first frame so the MethodChannel is bound and ready.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await BlacklistRepository.instance.syncToNative();
  });

  runApp(const HarmonyApp());
}
