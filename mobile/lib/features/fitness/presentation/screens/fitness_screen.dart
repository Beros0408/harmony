import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(
        title: 'Fitness & Performance',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: HarmonyEmptyState(
        icon: Icons.directions_run,
        title: 'Bientôt disponible',
        subtitle: 'Le suivi fitness et les performances sportives seront implémentés au Sprint 5.',
        cta: 'Retour au tableau de bord',
        onCtaTap: () => context.go(RouteNames.dashboard),
      ),
    );
  }
}
