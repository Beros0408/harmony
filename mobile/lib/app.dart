import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'core/language/language_cubit.dart';
import 'core/router/app_router.dart';
import 'core/security/secure_storage.dart';
import 'core/theme/system_ui_adapter.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/call_filter/data/repositories/blacklist_repository.dart';
import 'features/call_filter/logic/blacklist_cubit.dart';
import 'features/parental/data/repositories/child_profile_repository.dart';
import 'features/parental/data/repositories/location_repository.dart';
import 'features/parental/data/repositories/safe_zone_repository.dart';
import 'features/parental/data/repositories/sos_alert_repository.dart';
import 'features/parental/data/services/location_service.dart';
import 'features/parental/logic/child_profile_cubit.dart';
import 'features/parental/logic/location_cubit.dart';
import 'features/parental/logic/safe_zone_cubit.dart';
import 'features/parental/logic/sos_cubit.dart';
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
        // Sprint 3 — Parental
        BlocProvider(
          create: (_) => ChildProfileCubit(ChildProfileRepository.instance),
        ),
        BlocProvider(
          create: (_) => SafeZoneCubit(SafeZoneRepository.instance),
        ),
        BlocProvider(
          create: (_) => LocationCubit(
            LocationService.instance,
            LocationRepository.instance,
          ),
        ),
        BlocProvider(
          create: (_) => SosCubit(
            SosAlertRepository.instance,
            LocationRepository.instance,
            LocationService.instance,
          ),
        ),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              SystemUiAdapter.apply(themeMode);
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
