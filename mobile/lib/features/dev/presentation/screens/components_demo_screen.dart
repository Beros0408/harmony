import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_audio_waveform.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_metric_card.dart';
import '../../../../shared/widgets/harmony_search_bar.dart';
import '../../../../shared/widgets/harmony_status_dot.dart';
import '../../../../shared/widgets/harmony_toggle.dart';

class ComponentsDemoScreen extends StatefulWidget {
  const ComponentsDemoScreen({super.key});

  @override
  State<ComponentsDemoScreen> createState() => _ComponentsDemoScreenState();
}

class _ComponentsDemoScreenState extends State<ComponentsDemoScreen> {
  bool _filterEnabled = true;
  bool _parentalEnabled = false;
  double _waveformProgress = 0.35;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HarmonyAppBar(
        title: 'Design System',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('COMPOSANTS DU DESIGN SYSTEM', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),

          HarmonyCard(
            title: 'Boutons',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                HarmonyButton(label: 'Primary', onPressed: () {}),
                HarmonyButton(label: 'Secondary', onPressed: () {}, variant: HarmonyButtonVariant.secondary),
                HarmonyButton(label: 'Danger', onPressed: () {}, variant: HarmonyButtonVariant.danger),
                HarmonyButton(label: 'Ghost', onPressed: () {}, variant: HarmonyButtonVariant.ghost),
                HarmonyButton(label: 'Chargement', onPressed: () {}, isLoading: true),
                HarmonyButton(label: 'Avec icône', onPressed: () {}, icon: Icons.add),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const HarmonyCard(
            title: 'Badges',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                HarmonyBadge(label: 'Succès', variant: HarmonyBadgeVariant.success),
                HarmonyBadge(label: 'Avertissement', variant: HarmonyBadgeVariant.warning),
                HarmonyBadge(label: 'Danger', variant: HarmonyBadgeVariant.danger),
                HarmonyBadge(label: 'Info', variant: HarmonyBadgeVariant.info),
                HarmonyBadge(label: 'Purple', variant: HarmonyBadgeVariant.purple),
                HarmonyBadge(label: 'Rose', variant: HarmonyBadgeVariant.rose),
                HarmonyBadge(label: 'Muet', variant: HarmonyBadgeVariant.muted),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const HarmonyCard(
            title: 'Indicateurs de statut',
            child: Row(
              children: [
                HarmonyStatusDot(status: HarmonyStatus.online, pulse: true),
                SizedBox(width: AppSpacing.lg),
                HarmonyStatusDot(status: HarmonyStatus.warning),
                SizedBox(width: AppSpacing.lg),
                HarmonyStatusDot(status: HarmonyStatus.error),
                SizedBox(width: AppSpacing.lg),
                HarmonyStatusDot(status: HarmonyStatus.offline),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          HarmonyCard(
            title: 'Interrupteurs',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HarmonyToggle(
                  value: _filterEnabled,
                  onChanged: (v) => setState(() => _filterEnabled = v),
                  label: "Filtrage d'appels",
                ),
                const SizedBox(height: AppSpacing.md),
                HarmonyToggle(
                  value: _parentalEnabled,
                  onChanged: (v) => setState(() => _parentalEnabled = v),
                  label: 'Contrôle parental',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const HarmonyCard(
            title: 'Métriques',
            child: Row(
              children: [
                Expanded(
                  child: HarmonyMetricCard(
                    icon: Icons.directions_walk,
                    iconColor: AppColors.accentGreen,
                    value: '6 842',
                    label: 'Pas',
                    unit: 'pas',
                    trend: 12.5,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HarmonyMetricCard(
                    icon: Icons.local_fire_department_outlined,
                    iconColor: AppColors.accentAmber,
                    value: '312',
                    label: 'Calories',
                    unit: 'kcal',
                    trend: -3.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          HarmonyCard(
            title: 'Waveform audio',
            child: Column(
              children: [
                HarmonyAudioWaveform(
                  progress: _waveformProgress,
                  isPlaying: false,
                ),
                const SizedBox(height: AppSpacing.md),
                Slider(
                  value: _waveformProgress,
                  onChanged: (v) => setState(() => _waveformProgress = v),
                  activeColor: AppColors.accentBlue,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const HarmonyCard(
            title: 'Recherche',
            child: HarmonySearchBar(hintText: 'Rechercher un contact...'),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          Center(
            child: Text(
              'Harmony v0.3.0 · Sprint C3',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
