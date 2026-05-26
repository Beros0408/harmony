import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_list_tile.dart';
import '../../../../shared/widgets/harmony_status_dot.dart';
import '../../../../shared/widgets/harmony_toggle.dart';
import '../../data/mock/security_mocks.dart';
import '../../data/native/call_filter_channel.dart';
import '../../data/repositories/blacklist_repository.dart';
import '../../logic/blacklist_cubit.dart';

class CallFilterScreen extends StatefulWidget {
  const CallFilterScreen({super.key});

  @override
  State<CallFilterScreen> createState() => _CallFilterScreenState();
}

class _CallFilterScreenState extends State<CallFilterScreen>
    with WidgetsBindingObserver {
  int _activeModeIndex = 0;
  late List<bool> _ruleStates;
  bool _isDefaultScreeningApp = false;
  List<BlockedCallEntry> _recentCalls = [];

  @override
  void initState() {
    super.initState();
    _ruleStates = kFilterRules.map((r) => r.defaultEnabled).toList();
    WidgetsBinding.instance.addObserver(this);
    _checkScreeningStatus();
    BlacklistRepository.instance.syncToNative();
    _loadRecentCalls();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkScreeningStatus();
  }

  Future<void> _checkScreeningStatus() async {
    final active = await CallFilterChannel.isDefaultScreeningApp();
    if (mounted) setState(() => _isDefaultScreeningApp = active);
  }

  Future<void> _requestRole() async {
    await CallFilterChannel.requestScreeningRole();
  }

  Future<void> _loadRecentCalls() async {
    final calls = await CallFilterChannel.getBlockedCalls();
    if (mounted) setState(() => _recentCalls = calls.take(3).toList());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final modeTitles = [
      l10n.securityModeNormal,
      l10n.securityModeFocus,
      l10n.securityModeNight,
    ];

    return Scaffold(
      appBar: HarmonyAppBar(title: l10n.securityScreenTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 0 — Bannière statut CallScreeningService
          _ScreeningStatusBanner(
            isActive: _isDefaultScreeningApp,
            l10n: l10n,
            onActivate: _requestRole,
          ),
          const SizedBox(height: AppSpacing.lg),

          // A — KPIs
          _KpiRow(),
          const SizedBox(height: AppSpacing.xxl),

          // B — Modes
          _SectionHeader(title: l10n.securitySectionActiveMode),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kFilterModes.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (_, i) => _ModeCard(
                mode: kFilterModes[i],
                title: modeTitles[i],
                isActive: _activeModeIndex == i,
                onTap: () {
                  setState(() => _activeModeIndex = i);
                  BlacklistRepository.instance.setMode(kFilterModes[i].type);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // C — Règles
          _SectionHeader(title: l10n.securitySectionRules),
          const SizedBox(height: AppSpacing.sm),
          BlocBuilder<BlacklistCubit, BlacklistState>(
            builder: (context, blacklistState) {
              final count = blacklistState.entries.length;
              final dynamicRuleTexts = [
                (l10n.securityRuleUnknownNumbers, l10n.securityRuleUnknownNumbersDesc),
                (l10n.securityRuleSpam, l10n.securityRuleSpamDesc),
                (l10n.securityRuleBlacklist, l10n.securityRuleBlacklistDesc(count)),
                (l10n.securityRuleForeign, l10n.securityRuleForeignDesc),
                (l10n.securityRuleWhitelist, l10n.securityRuleWhitelistDesc(8)),
              ];
              return HarmonyCard(
                padding: AppSpacing.md,
                child: Column(
                  children: List.generate(kFilterRules.length, (i) {
                    final rule = kFilterRules[i];
                    final isBlacklist = rule.type == FilterRuleType.blacklist;
                    return HarmonyListTile(
                      leadingIcon: rule.icon,
                      leadingColor: AppColors.accentBlue,
                      title: dynamicRuleTexts[i].$1,
                      subtitle: dynamicRuleTexts[i].$2,
                      trailing: isBlacklist
                          ? const Icon(Icons.chevron_right, color: AppColors.textMuted)
                          : HarmonyToggle(
                              value: _ruleStates[i],
                              onChanged: (v) => setState(() => _ruleStates[i] = v),
                            ),
                      onTap: isBlacklist
                          ? () => context.push(RouteNames.blacklist)
                          : null,
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // D — Derniers appels bloqués
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionHeader(title: l10n.securitySectionRecentBlocked),
              GestureDetector(
                onTap: () => context.push(RouteNames.callLog),
                child: Text(l10n.securitySeeAll, style: Theme.of(context).textTheme.labelMedium),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: _recentCalls.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Text(
                      '—',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  )
                : Column(
                    children: _recentCalls
                        .map(
                          (call) => HarmonyListTile(
                            leadingIcon: Icons.phone_disabled,
                            leadingColor: AppColors.accentRed,
                            title: call.phoneNumber.isEmpty ? 'Numéro inconnu' : call.phoneNumber,
                            subtitle: '${call.latencyMs}ms · ${call.timestamp.hour.toString().padLeft(2, '0')}:${call.timestamp.minute.toString().padLeft(2, '0')}',
                          ),
                        )
                        .toList(),
                  ),
          ),
          // E — Journal des appels bloqués
          _SectionHeader(title: l10n.callLogScreenTitle),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: HarmonyListTile(
              leadingIcon: Icons.format_list_bulleted_rounded,
              leadingColor: AppColors.accentRed,
              title: l10n.callLogScreenTitle,
              subtitle: l10n.securityStatsBlocked,
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
              onTap: () => context.push(RouteNames.callLog),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // F — Messagerie vocale
          _SectionHeader(title: l10n.voicemailScreenTitle),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: HarmonyListTile(
              leadingIcon: Icons.voicemail_rounded,
              leadingColor: AppColors.accentPurple,
              title: l10n.voicemailScreenTitle,
              subtitle: l10n.voicemailMockNote,
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
              ),
              onTap: () => context.push(RouteNames.voicemail),
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
    final l10n = AppLocalizations.of(context)!;
    return HarmonyCard(
      padding: AppSpacing.lg,
      child: Row(
        children: [
          _KpiItem(value: '${kSecurityKpis.blocked}', label: l10n.securityStatsBlocked, color: AppColors.accentRed),
          _Divider(),
          _KpiItem(value: '${kSecurityKpis.rules}', label: l10n.securityStatsRules, color: AppColors.accentBlue),
          _Divider(),
          _KpiItem(value: '${kSecurityKpis.accuracy}%', label: l10n.securityStatsPrecision, color: AppColors.accentGreen),
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
          Text(label, style: Theme.of(context).textTheme.labelSmall),
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
  const _ModeCard({
    required this.mode,
    required this.title,
    required this.isActive,
    required this.onTap,
  });
  final FilterMode mode;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: isActive ? mode.color : cs.outline,
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
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isActive ? cs.onSurface : cs.onSurfaceVariant,
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
    return Text(title, style: Theme.of(context).textTheme.titleSmall);
  }
}

// ─── Bannière statut CallScreeningService ───────────────────────────────────

class _ScreeningStatusBanner extends StatelessWidget {
  const _ScreeningStatusBanner({
    required this.isActive,
    required this.l10n,
    required this.onActivate,
  });

  final bool isActive;
  final AppLocalizations l10n;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return HarmonyCard(
        padding: AppSpacing.md,
        child: Row(
          children: [
            const HarmonyStatusDot(status: HarmonyStatus.online, pulse: true),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                l10n.callScreeningActiveStatus,
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const HarmonyBadge(
              label: 'Android',
              variant: HarmonyBadgeVariant.success,
            ),
          ],
        ),
      );
    }

    return HarmonyCard(
      padding: AppSpacing.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.accentAmber,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.callScreeningEnableTitle,
                style: const TextStyle(
                  color: AppColors.accentAmber,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.callScreeningEnableDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onActivate,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
              child: Text(l10n.callScreeningEnableButton),
            ),
          ),
        ],
      ),
    );
  }
}
