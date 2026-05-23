import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_snack_bar.dart';
import '../../../../shared/widgets/harmony_toggle.dart';
import '../../data/mock/agenda_mocks.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late List<bool> _modeStates;

  @override
  void initState() {
    super.initState();
    _modeStates = kDayModes.map((m) => m.defaultEnabled).toList();
  }

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
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 100,
            ),
            children: [
              // A — Date header
              _DateHeader(onChevronTap: () {
                HarmonySnackBar.show(context, message: 'Navigation jour à venir');
              },),
              const SizedBox(height: AppSpacing.xxl),

              // B — Modes du jour
              const _SectionHeader(title: 'MODES DU JOUR'),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: List.generate(kDayModes.length, (i) {
                  final mode = kDayModes[i];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < kDayModes.length - 1 ? AppSpacing.md : 0,
                      ),
                      child: _DayModeCard(
                        mode: mode,
                        isEnabled: _modeStates[i],
                        onChanged: (v) => setState(() => _modeStates[i] = v),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // C — Événements
              const _SectionHeader(title: 'MES ÉVÉNEMENTS DU JOUR'),
              const SizedBox(height: AppSpacing.md),
              ...kTodayEvents.map((event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _EventCard(event: event),
              ),),
            ],
          ),

          // D — FAB en bas
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
            child: HarmonyButton(
              label: 'Nouvel événement',
              icon: Icons.add,
              onPressed: () {
                HarmonySnackBar.show(
                  context,
                  message: "Création d'événement à venir au Sprint 4",
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date header ─────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.onChevronTap});
  final VoidCallback onChevronTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textMuted),
          onPressed: onChevronTap,
        ),
        Expanded(
          child: Column(
            children: [
              Text("Aujourd'hui", style: AppTypography.textTheme.titleMedium),
              Text('samedi 24 mai 2026', style: AppTypography.textTheme.bodySmall),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textMuted),
          onPressed: onChevronTap,
        ),
      ],
    );
  }
}

// ─── Day mode card ────────────────────────────────────────────────────────────

class _DayModeCard extends StatelessWidget {
  const _DayModeCard({
    required this.mode,
    required this.isEnabled,
    required this.onChanged,
  });
  final DayMode mode;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: isEnabled ? mode.color.withValues(alpha: 0.4) : AppColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: mode.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(mode.icon, color: mode.color, size: 15),
              ),
              HarmonyToggle(value: isEnabled, onChanged: onChanged),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(mode.title, style: AppTypography.textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(mode.subtitle, style: AppTypography.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Event card ───────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final AgendaEvent event;

  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      padding: 0,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: event.accentColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.xl)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: AppTypography.textTheme.labelLarge),
                    const SizedBox(height: 2),
                    Text(event.timeRange, style: AppTypography.textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(event.detailIcon, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: AppSpacing.xs),
                        Text(event.detailText, style: AppTypography.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.textTheme.titleSmall);
  }
}
