import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/security/secure_storage.dart';
import 'core/services/harmony_services.dart';
import 'core/theme/theme_cubit.dart';
import 'features/kids/data/services/kids_link_verification_service.dart';
import 'features/kids/data/services/kids_storage.dart';
import 'features/kids/presentation/kids_admin_screen.dart';
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

  runApp(HarmonyKidsApp(initialChildId: storedChildId));
}

class HarmonyKidsApp extends StatelessWidget {
  const HarmonyKidsApp({super.key, this.initialChildId});

  final String? initialChildId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(SecureStorageService()),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          title: 'Harmony Kids',
          debugShowCheckedModeBanner: false,
          theme: HarmonyTheme.light(),
          darkTheme: HarmonyTheme.dark(),
          themeMode: themeMode,
          // Si déjà appairé → admin screen ; sinon → pairing screen
          home: initialChildId != null
              ? KidsAdminScreen(childId: initialChildId)
              : const KidsPairingScreen(),
        ),
      ),
    );
  }
}
