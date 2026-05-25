import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'core/language/language_cubit.dart';
import 'core/router/app_router.dart';
import 'core/security/secure_storage.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/call_filter/data/repositories/blacklist_repository.dart';
import 'features/call_filter/logic/blacklist_cubit.dart';
import 'shared/theme/harmony_theme.dart';
import 'shared/widgets/harmony_responsive_wrapper.dart';

class HarmonyApp extends StatelessWidget {
  const HarmonyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LanguageCubit(SecureStorageService())..load(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(SecureStorageService())..load(),
        ),
        BlocProvider(
          create: (_) => AuthBloc(
            repository: AuthRepository(storage: SecureStorageService()),
          )..add(const AuthCheckRequested()),
        ),
        BlocProvider(
          create: (_) => BlacklistCubit(BlacklistRepository.instance)
            ..loadEntries(),
        ),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                title: 'Harmony',
                debugShowCheckedModeBanner: false,
                theme: HarmonyTheme.light(),
                darkTheme: HarmonyTheme.dark(),
                themeMode: themeMode,
                routerConfig: appRouter,
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => HarmonyResponsiveWrapper(
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
