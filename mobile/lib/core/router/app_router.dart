import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/agenda/presentation/screens/event_detail_screen.dart';
import '../../features/agenda/presentation/screens/event_editor_screen.dart';
import '../../features/agenda/presentation/screens/tasks_screen.dart';
import '../../features/agenda/presentation/screens/google_calendar_settings_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/call_filter/presentation/screens/blacklist_screen.dart';
import '../../features/call_filter/presentation/screens/call_filter_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/fitness/presentation/screens/fitness_screen.dart';
import '../../features/parental/presentation/screens/child_detail_screen.dart';
import '../../features/parental/presentation/screens/child_settings_screen.dart';
import '../../features/parental/presentation/screens/parental_screen.dart';
import '../../features/parental/presentation/screens/safe_zone_editor_screen.dart';
import '../../features/parental/presentation/screens/sos_active_screen.dart';
import '../../features/parental/presentation/screens/sos_contacts_screen.dart';
import '../../features/parental/presentation/screens/trip_history_screen.dart';
import '../../features/contacts/presentation/screens/contacts_screen.dart';
import '../../features/messages/presentation/screens/messages_filter_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/call_log/presentation/screens/call_log_screen.dart';
import '../../features/meditation/presentation/screens/meditation_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/subscription/presentation/screens/paywall_screen.dart';
import '../../features/subscription/presentation/screens/subscription_status_screen.dart';
import '../../features/voicemail/presentation/screens/voicemail_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'route_names.dart';

// Transition slide droite→gauche conforme au design system (200ms ease-in-out)
CustomTransitionPage<void> _slidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: false,
  errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.auth,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: RouteNames.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: RouteNames.security,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const CallFilterScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.family,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const ParentalScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.fitness,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const FitnessScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.agenda,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const AgendaScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.contacts,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const ContactsScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.callLog,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const CallLogScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.voicemail,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const VoicemailScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.settings,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.blacklist,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const BlacklistScreen(),
      ),
    ),
    // ── Sprint 6 — Messages ───────────────────────────────────────────────
    GoRoute(
      path: RouteNames.messages,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const MessagesFilterScreen(),
      ),
    ),
    // ── Sprint 4 — Agenda ─────────────────────────────────────────────────
    GoRoute(
      path: '${RouteNames.agendaEvent}/:id',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: RouteNames.agendaEventEdit,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const EventEditorScreen(),
      ),
    ),
    GoRoute(
      path: '${RouteNames.agendaEventEdit}/:id',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: EventEditorScreen(eventId: state.pathParameters['id']),
      ),
    ),
    GoRoute(
      path: RouteNames.agendaTasks,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const TasksScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.agendaGoogle,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const GoogleCalendarSettingsScreen(),
      ),
    ),
    // ── Sprint 3 — Parental ───────────────────────────────────────────────
    GoRoute(
      path: '${RouteNames.childDetail}/:id',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: ChildDetailScreen(childId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '${RouteNames.childDetail}/:id/history',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: TripHistoryScreen(childId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '${RouteNames.childDetail}/:id/settings',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: ChildSettingsScreen(childId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '${RouteNames.childDetail}/:id/sos-contacts',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: SosContactsScreen(childId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: RouteNames.safeZoneEditor,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const SafeZoneEditorScreen(),
      ),
    ),
    GoRoute(
      path: '${RouteNames.safeZoneEditor}/:id',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: SafeZoneEditorScreen(zoneId: state.pathParameters['id']),
      ),
    ),
    GoRoute(
      path: RouteNames.sosActive,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const SosActiveScreen(),
      ),
    ),
    // ── Mini-Sprint Visuels — Méditation ─────────────────────────────────────
    GoRoute(
      path: RouteNames.meditation,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const MeditationScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.paywall,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const PaywallScreen(),
      ),
    ),
    GoRoute(
      path: RouteNames.subscriptionStatus,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const SubscriptionStatusScreen(),
      ),
    ),
  ],
);

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.accentRed, size: 48),
            const SizedBox(height: 16),
            Text('Page introuvable', style: AppTypography.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Route inconnue',
              style: AppTypography.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go(RouteNames.dashboard),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
