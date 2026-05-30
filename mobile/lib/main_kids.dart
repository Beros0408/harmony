import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/security/secure_storage.dart';
import 'core/services/harmony_services.dart';
import 'core/theme/theme_cubit.dart';
import 'features/kids/presentation/kids_pairing_screen.dart';
import 'shared/theme/harmony_theme.dart';

/// Point d'entrée de l'app compagnon "Harmony Kids".
/// Init allégée : pas d'AdMob, RevenueCat, ni repositories parentaux.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Réseau partagé (DioClient + TokenStorage) — même mécanisme que l'app parent
  HarmonyServices.init();

  runApp(const HarmonyKidsApp());
}

class HarmonyKidsApp extends StatelessWidget {
  const HarmonyKidsApp({super.key});

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
          home: const KidsPairingScreen(),
        ),
      ),
    );
  }
}
