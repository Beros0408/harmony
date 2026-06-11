import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/security/secure_storage.dart';
import 'core/services/harmony_services.dart';
import 'core/theme/theme_cubit.dart';
import 'features/kids/data/services/kids_link_verification_service.dart';
import 'features/kids/data/services/kids_storage.dart';
import 'features/kids/data/services/screen_time_blocking_service.dart';
import 'features/kids/data/services/screen_time_limits_fetch_service.dart';
import 'features/kids/data/services/screen_time_upload_service.dart';
import 'features/kids/data/services/screen_time_warning_service.dart';
import 'features/kids/presentation/kids_admin_screen.dart';
import 'features/kids/presentation/kids_onboarding_screen.dart';
import 'features/kids/presentation/kids_pairing_screen.dart';
import 'shared/theme/harmony_theme.dart';

/// Point d'entrée de l'app compagnon "Harmony Kids".
/// Init allégée : pas d'AdMob, RevenueCat, ni repositories parentaux.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Réseau partagé (DioClient + TokenStorage) — même mécanisme que l'app parent
  HarmonyServices.init();

  // Si l'enfant est déjà appairé (child_id en stockage sécurisé),
  // on vérifie d'abord que le lien existe encore côté serveur.
  String? storedChildId = await KidsStorage.instance.getChildId();
  // Sprint S16 — lu avant runApp pour décider si l'onboarding enfant doit s'afficher.
  final kidsOnboardingDone = await KidsStorage.instance.getKidsOnboardingDone();

  if (storedChildId != null) {
    try {
      final linked =
          await KidsLinkVerificationService.instance.isLinked(storedChildId);
      if (!linked) {
        // Lien supprimé côté serveur → nettoyage local, retour à l'appairage
        await KidsStorage.instance.clearChildId();
        storedChildId = null;
      }
    } on DioException catch (e) {
      // Serveur injoignable (pas de réseau, timeout…) → conserver l'état local.
      // "Réseau indisponible" ≠ "lien supprimé" : on ne délie jamais par erreur.
      debugPrint('[main_kids] vérif lien: réseau KO (${e.type}), état conservé');
    } catch (e) {
      // Erreur inattendue → conserver l'état par précaution
      debugPrint('[main_kids] vérif lien: erreur inattendue, état conservé ($e)');
    }
  }

  // Démarre la remontée du temps d'écran si la permission est déjà accordée
  // (lance immédiatement + timer 30 min). Silencieux si permission absente.
  if (storedChildId != null) {
    ScreenTimeUploadService.instance.start();
    // Polling des limites toutes les 5 min + push de la liste de blocage toutes les 30 s.
    ScreenTimeLimitsFetchService.instance.start();
    ScreenTimeBlockingService.instance.start();
    // Sprint 5D-1 : avertissements progressifs 10/5/1 min avant le blocage.
    await ScreenTimeWarningService.instance.init();
    ScreenTimeWarningService.instance.start();
  }

  runApp(
    HarmonyKidsApp(
      initialChildId: storedChildId,
      kidsOnboardingDone: kidsOnboardingDone,
    ),
  );
}

class HarmonyKidsApp extends StatelessWidget {
  const HarmonyKidsApp({
    super.key,
    this.initialChildId,
    this.kidsOnboardingDone = false,
  });

  final String? initialChildId;
  // Sprint S16 — false = onboarding non encore vu, true = déjà complété.
  final bool kidsOnboardingDone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(SecureStorageService()),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          title: 'KimiaCare Kids',
          debugShowCheckedModeBanner: false,
          theme: HarmonyTheme.light(),
          darkTheme: HarmonyTheme.dark(),
          themeMode: themeMode,
          // Gate onboarding enfant (Sprint S16) :
          //   appairé + onboarding vu     → KidsAdminScreen (nominal)
          //   appairé + onboarding absent → KidsOnboardingScreen (une seule fois)
          //   non appairé                 → KidsPairingScreen
          home: initialChildId != null
              ? (kidsOnboardingDone
                  ? KidsAdminScreen(childId: initialChildId)
                  : KidsOnboardingScreen(childId: initialChildId!))
              : const KidsPairingScreen(),
        ),
      ),
    );
  }
}
