import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/app_router.dart';
import 'core/security/secure_storage.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'shared/theme/app_theme.dart';

class HarmonyApp extends StatelessWidget {
  const HarmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        repository: AuthRepository(storage: SecureStorageService()),
      )..add(const AuthCheckRequested()),
      child: MaterialApp.router(
        title: 'Harmony',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
