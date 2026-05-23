import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_list_tile.dart';
import '../../../../shared/widgets/harmony_toggle.dart';
import '../../data/mock/security_mocks.dart';

class CallFilterScreen extends StatefulWidget {
  const CallFilterScreen({super.key});

  @override
  State<CallFilterScreen> createState() => _CallFilterScreenState();
}

class _CallFilterScreenState extends State<CallFilterScreen> {
  int _activeModeIndex = 0;
  late List<bool> _ruleStates;

  @override
  void initState() {
    super.initState();
    _ruleStates = kFilterRules.map((r) => r.defaultEnabled).toList();
  }

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
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // A — KPIs
          _KpiRow(),
          const SizedBox(height: AppSpacing.xxl),

          // B — Modes
          const _SectionHeader(title: 'MODE ACTIF'),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kFilterModes.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, i) => _ModeCard(
                mode: kFilterModes[i],
                isActive: _activeModeIndex == i,
                onTap: () => setState(() => _activeModeIndex = i),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // C — Règles
          const _SectionHeader(title: 'RÈGLES DE FILTRAGE'),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: List.generate(kFilterRules.length, (i) {
                final rule = kFilterRules[i];
                return HarmonyListTile(
                  leadingIcon: rule.icon,
                  leadingColor: AppColors.accentBlue,
                  title: rule.title,
                  subtitle: rule.subtitle,
                  trailing: HarmonyToggle(
                    value: _ruleStates[i],
                    onChanged: (v) => setState(() => _ruleStates[i] = v),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // D — Derniers appels bloqués
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionHeader(title: 'DERNIERS APPELS BLOQUÉS'),
              Text('Voir tout', style: AppTypography.textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: kRecentBlockedCalls.map((call) => HarmonyListTile(
                leadingIcon: Icons.phone_disabled,
                leadingColor: AppColors.accentRed,
                title: call.number,
                subtitle: call.detail,
              ),).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ─── KPI row ────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      padding: AppSpacing.lg,
      child: Row(
        children: [
          _KpiItem(value: '${kSecurityKpis.blocked}', label: 'Bloqués', color: AppColors.accentRed),
          _Divider(),
          _KpiItem(value: '${kSecurityKpis.rules}', label: 'Règles', color: AppColors.accentBlue),
          _Divider(),
          _KpiItem(value: '${kSecurityKpis.accuracy}%', label: 'Précision', color: AppColors.accentGreen),
        ],
      ),
    );
  }
}

class _KpiItem extends StatelessWidget {
  const _KpiItem({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTypography.monoMetric.copyWith(color: color, fontSize: 28)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.borderDefault);
  }
}

// ─── Mode card ──────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.isActive, required this.onTap});
  final FilterMode mode;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: isActive ? mode.color : AppColors.borderDefault,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: mode.color.withValues(alpha: 0.12),
                borderRadius: AppRadius.smRadius,
              ),
              child: Icon(mode.icon, color: mode.color, size: 16),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              mode.title,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.textTheme.titleSmall);
  }
}
