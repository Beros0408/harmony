import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/call_filter/presentation/screens/call_filter_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/fitness/presentation/screens/fitness_screen.dart';
import '../../features/parental/presentation/screens/parental_screen.dart';
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
  initialLocation: RouteNames.auth,
  debugLogDiagnostics: false,
  errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  routes: [
    GoRoute(
      path: RouteNames.splash,
      redirect: (_, __) => RouteNames.auth,
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
      path: RouteNames.settings,
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const _PlaceholderScreen(title: 'Paramètres'),
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
            const Icon(
              Icons.error_outline,
              color: AppColors.accentRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Page introuvable',
              style: AppTypography.textTheme.titleLarge,
            ),
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

// Écran placeholder générique pour les routes non encore implémentées
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'À implémenter',
          style: AppTypography.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
