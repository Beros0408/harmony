import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/services/harmony_services.dart';
import 'core/services/notification_service.dart';
import 'features/call_filter/data/repositories/blacklist_repository.dart';
import 'features/parental/data/repositories/child_profile_repository.dart';
import 'features/parental/data/repositories/safe_zone_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  // Sprint 5 — Services partagés (TokenStorage + DioClient avec intercepteur JWT)
  HarmonyServices.init();

  // Sprint 4 — Notifications + timezone (timezone init est dans NotificationService.init)
  await NotificationService.instance.init();

  // Repositories existants
  await BlacklistRepository.instance.init();

  // Sprint 3 — Repositories parental (seed des enfants + zones par défaut)
  await ChildProfileRepository.instance.init();
  await SafeZoneRepository.instance.init();

  // Push blacklist snapshot to Kotlin CallDecisionEngine at startup.
  // Runs after the first frame so the MethodChannel is bound and ready.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await BlacklistRepository.instance.syncToNative();
  });

  runApp(const HarmonyApp());
}
