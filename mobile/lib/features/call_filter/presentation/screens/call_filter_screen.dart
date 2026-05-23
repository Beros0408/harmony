import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';

class CallFilterScreen extends StatelessWidget {
  const CallFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(
        title: 'Sécurité & Filtrage',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: HarmonyEmptyState(
        icon: Icons.shield_outlined,
        title: 'Bientôt disponible',
        subtitle: 'Le filtrage d\'appels et la sécurité seront implémentés au Sprint 2.',
        cta: 'Retour au tableau de bord',
        onCtaTap: () => context.go(RouteNames.dashboard),
      ),
    );
  }
}
