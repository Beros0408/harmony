import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';
import '../../data/models/message_rule.dart';
import '../../logic/messages_cubit.dart';
import '../widgets/captured_message_tile.dart';
import '../widgets/message_rule_form_sheet.dart';

class MessagesFilterScreen extends StatefulWidget {
  const MessagesFilterScreen({super.key});

  @override
  State<MessagesFilterScreen> createState() => _MessagesFilterScreenState();
}

class _MessagesFilterScreenState extends State<MessagesFilterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MessagesCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: l10n.messagesScreenTitle,
        actions: [
          BlocBuilder<MessagesCubit, MessagesState>(
            builder: (context, state) => IconButton(
              icon: state is MessagesLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_outlined),
              tooltip: l10n.messagesRefreshTooltip,
              onPressed: state is MessagesLoading
                  ? null
                  : () => context.read<MessagesCubit>().load(),
            ),
          ),
        ],
      ),
      body: BlocBuilder<MessagesCubit, MessagesState>(
        builder: (context, state) => switch (state) {
          MessagesInitial() || MessagesLoading() =>
            const Center(child: CircularProgressIndicator()),
          MessagesError(:final message) => HarmonyEmptyState(
              icon: Icons.error_outline,
              title: 'Erreur',
              subtitle: message,
              cta: 'Réessayer',
              onCtaTap: () => context.read<MessagesCubit>().load(),
            ),
          MessagesPermissionDenied() => _SmsPermissionCard(l10n: l10n),
          MessagesListenerDisabled() => HarmonyEmptyState(
              icon: Icons.notifications_off_outlined,
              title: l10n.messagesListenerDisabledTitle,
              subtitle: l10n.messagesListenerDisabledSubtitle,
              cta: l10n.messagesListenerEnableCta,
              onCtaTap: () =>
                  context.read<MessagesCubit>().requestListenerAccess(),
            ),
          MessagesLoaded(:final messages, :final rules, :final listenerEnabled) =>
            _MessagesBody(
              state: MessagesLoaded(
                messages: messages,
                rules: rules,
                listenerEnabled: listenerEnabled,
              ),
            ),
        },
      ),
      floatingActionButton: BlocBuilder<MessagesCubit, MessagesState>(
        builder: (context, state) {
          if (state is! MessagesLoaded) return const SizedBox.shrink();
          return FloatingActionButton(
            heroTag: 'messages_fab',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BlocProvider.value(
                value: context.read<MessagesCubit>(),
                child: const MessageRuleFormSheet(),
              ),
            ),
            backgroundColor: AppColors.accentBlue,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }
}

// ─── Corps principal ──────────────────────────────────────────────────────────

class _MessagesBody extends StatelessWidget {
  const _MessagesBody({required this.state});

  final MessagesLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Section 1 — Statut du listener
        _ListenerStatusCard(enabled: state.listenerEnabled),
        const SizedBox(height: AppSpacing.lg),

        // Section 2 — Stats
        _StatsRow(
          totalCount: state.totalCount,
          blockedCount: state.blockedCount,
          rulesCount: state.rules.length,
          l10n: l10n,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Section 3 — Règles
        if (state.rules.isNotEmpty) ...[
          Text(l10n.messagesSectionRules, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          ...state.rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _RuleCard(rule: rule),
              )),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Section 4 — Messages récents
        Text(l10n.messagesSectionRecent, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),

        if (state.messages.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.messagesEmptyState,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...state.messages.map(
            (msg) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: CapturedMessageTile(
                message: msg,
                onTap: () => context.push(RouteNames.messageDetail, extra: msg),
              ),
            ),
          ),

        // Note iOS limitation
        const SizedBox(height: AppSpacing.lg),
        _IosLimitationNote(),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

// ─── Statut du listener ───────────────────────────────────────────────────────

class _ListenerStatusCard extends StatelessWidget {
  const _ListenerStatusCard({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final color = enabled ? AppColors.accentGreen : AppColors.accentAmber;

    return HarmonyCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled
                      ? l10n.messagesListenerEnabledTitle
                      : l10n.messagesListenerDisabledTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  enabled
                      ? l10n.messagesListenerEnabledSubtitle
                      : l10n.messagesListenerDisabledSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          if (!enabled)
            TextButton(
              onPressed: () =>
                  context.read<MessagesCubit>().requestListenerAccess(),
              child: Text(l10n.messagesListenerEnableCta),
            ),
        ],
      ),
    );
  }
}

// ─── Statistiques ─────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalCount,
    required this.blockedCount,
    required this.rulesCount,
    required this.l10n,
  });

  final int totalCount;
  final int blockedCount;
  final int rulesCount;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          value: totalCount.toString(),
          label: l10n.messagesStatTotal,
          color: AppColors.accentBlue,
          icon: Icons.message_outlined,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          value: blockedCount.toString(),
          label: l10n.messagesStatBlocked,
          color: AppColors.accentRed,
          icon: Icons.block_outlined,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          value: rulesCount.toString(),
          label: l10n.messagesStatRules,
          color: AppColors.accentPurple,
          icon: Icons.rule_outlined,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: HarmonyCard(
        padding: AppSpacing.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carte règle ─────────────────────────────────────────────────────────────

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule});

  final MessageRule rule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return HarmonyCard(
      child: Row(
        children: [
          Icon(
            rule.action == RuleAction.block
                ? Icons.block_outlined
                : Icons.check_circle_outline,
            color: rule.action == RuleAction.block
                ? AppColors.accentRed
                : AppColors.accentGreen,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Flexible : évite overflow si le type est long (ex. "Plage horaire")
                    Flexible(
                      child: HarmonyBadge(
                        label: rule.ruleType.displayName,
                        variant: HarmonyBadgeVariant.info,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    HarmonyBadge(
                      label: rule.action.displayName,
                      variant: rule.action == RuleAction.block
                          ? HarmonyBadgeVariant.danger
                          : HarmonyBadgeVariant.success,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  rule.value.isEmpty ? l10n.messageRuleScheduleDisplay : rule.value,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider.value(
                    value: context.read<MessagesCubit>(),
                    child: MessageRuleFormSheet(rule: rule),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 18, color: AppColors.accentRed),
                onPressed: () =>
                    context.read<MessagesCubit>().deleteRule(rule.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Bloc demande de permission SMS ──────────────────────────────────────────

class _SmsPermissionCard extends StatelessWidget {
  const _SmsPermissionCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sms_failed_outlined,
                color: AppColors.accentRed,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.messagesPermissionRequiredTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.messagesPermissionRequiredSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () =>
                  context.read<MessagesCubit>().requestSmsAccess(),
              icon: const Icon(Icons.sms_outlined),
              label: Text(l10n.messagesPermissionAllowCta),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Note limitations iOS ─────────────────────────────────────────────────────

class _IosLimitationNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentAmber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline,
              color: AppColors.accentAmber, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.messagesIosLimitation,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
