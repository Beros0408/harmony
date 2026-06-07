import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'core/language/language_cubit.dart';
import 'core/router/app_router.dart';
import 'core/security/secure_storage.dart';
import 'core/services/harmony_services.dart';
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
// Sprint 4 — Agenda
import 'features/agenda/data/repositories/agenda_event_repository.dart';
import 'features/agenda/data/repositories/google_calendar_repository.dart';
import 'features/agenda/data/repositories/task_repository.dart';
import 'features/agenda/logic/agenda_event_cubit.dart';
import 'features/agenda/logic/calendar_view_cubit.dart';
import 'features/agenda/logic/google_calendar_cubit.dart';
import 'features/agenda/logic/task_cubit.dart';
// Sprint 5 — Contacts natifs
import 'features/contacts/data/repositories/native_contacts_repository.dart';
import 'features/contacts/logic/contacts_cubit.dart';
// Sprint 6 — Messages
import 'features/messages/data/repositories/native_messages_repository.dart';
import 'features/messages/logic/messages_cubit.dart';
// Sprint 7 — Fitness
import 'features/fitness/data/repositories/native_fitness_repository.dart';
import 'features/fitness/logic/fitness_cubit.dart';
// Sprint 8 — Paywall
import 'features/subscription/data/repositories/revenuecat_subscription_repository.dart';
import 'features/subscription/logic/subscription_cubit.dart';
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
            tokenStorage: HarmonyServices.tokenStorage,
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
        // Sprint 4 — Agenda
        BlocProvider(
          create: (_) => AgendaEventCubit(
            repository: AgendaEventRepository.instance,
          ),
        ),
        BlocProvider(create: (_) => CalendarViewCubit()),
        BlocProvider(
          create: (_) => TaskCubit(repository: TaskRepository.instance),
        ),
        BlocProvider(
          create: (_) =>
              GoogleCalendarCubit(repository: GoogleCalendarRepository.instance),
        ),
        // Sprint 5 — Contacts natifs
        BlocProvider(
          create: (_) => ContactsCubit(
            repository: NativeContactsRepository.instance,
          ),
        ),
        // Sprint 6 — Messages
        BlocProvider(
          create: (_) => MessagesCubit(
            repository: NativeMessagesRepository.instance,
          ),
        ),
        // Sprint 7 — Fitness
        BlocProvider(
          create: (_) => FitnessCubit(
            repository: NativeFitnessRepository.instance,
          ),
        ),
        // Sprint 8 — Paywall
        BlocProvider(
          create: (_) => SubscriptionCubit(
            repository: RevenueCatSubscriptionRepository.instance,
          )..load(),
        ),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              SystemUiAdapter.apply(themeMode);
              return MaterialApp.router(
                title: 'KimiaCare',
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
