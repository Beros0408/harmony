import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';

class ParentalScreen extends StatelessWidget {
  const ParentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(
        title: 'Famille & Contrôle parental',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: HarmonyEmptyState(
        icon: Icons.family_restroom,
        title: 'Bientôt disponible',
        subtitle: 'Le contrôle parental et la gestion de profils familiaux seront implémentés au Sprint 3.',
        cta: 'Retour au tableau de bord',
        onCtaTap: () => context.go(RouteNames.dashboard),
      ),
    );
  }
}
