import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/security/secure_storage.dart';
import 'core/services/harmony_services.dart';
import 'core/theme/theme_cubit.dart';
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
  // on va directement à l'écran admin + polling ; sinon, écran d'appairage.
  final storedChildId = await KidsStorage.instance.getChildId();

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
