import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(
        title: 'Agenda & Planification',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: HarmonyEmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'Bientôt disponible',
        subtitle: 'La gestion de l\'agenda et la planification seront implémentés au Sprint 4.',
        cta: 'Retour au tableau de bord',
        onCtaTap: () => context.go(RouteNames.dashboard),
      ),
    );
  }
}
