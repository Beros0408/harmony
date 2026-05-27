import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/core/constants/app_colors.dart';
import 'package:harmony/core/constants/app_spacing.dart';
import 'package:harmony/core/services/feature_gating_service.dart';
import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';
import 'package:harmony/features/call_filter/logic/blacklist_cubit.dart';
import 'package:harmony/features/call_filter/presentation/widgets/blacklist_form_sheet.dart';
import 'package:harmony/features/subscription/presentation/widgets/upgrade_prompt.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/widgets/ad_banner.dart';
import 'package:harmony/shared/widgets/harmony_app_bar.dart';
import 'package:harmony/shared/widgets/harmony_card.dart';
import 'package:harmony/shared/widgets/harmony_search_bar.dart';

class BlacklistScreen extends StatefulWidget {
  const BlacklistScreen({super.key});

  @override
  State<BlacklistScreen> createState() => _BlacklistScreenState();
}

class _BlacklistScreenState extends State<BlacklistScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BlacklistCubit>().loadEntries();
  }

  Future<void> _openAddSheet() async {
    final state = context.read<BlacklistCubit>().state;
    final count = state.entries.length;
    if (!FeatureGatingService.instance.canAddBlacklistEntry(count)) {
      await UpgradePrompt.show(
        context,
        title: 'Blacklist complète',
        description:
            'Le plan gratuit est limité à 10 entrées. Passez à Premium pour une blacklist illimitée.',
        icon: Icons.block_outlined,
      );
      return;
    }
    await showBlacklistFormSheet(context: context);
  }

  Future<void> _openEditSheet(BlacklistEntry entry) async {
    await showBlacklistFormSheet(context: context, entry: entry);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(title: l10n.blacklistScreenTitle),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSheet,
        backgroundColor: AppColors.accentRed,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: HarmonySearchBar(
              hintText: l10n.blacklistSearchHint,
              onChanged: (q) => context.read<BlacklistCubit>().search(q),
            ),
          ),
          Expanded(
            child: BlocBuilder<BlacklistCubit, BlacklistState>(
              builder: (context, state) {
                if (state.isLoading && state.entries.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.entries.isEmpty) {
                  return _EmptyState(l10n: l10n);
                }
                return _BlacklistList(
                  entries: state.entries,
                  onEdit: _openEditSheet,
                  onDelete: (id) =>
                      context.read<BlacklistCubit>().deleteEntry(id),
                );
              },
            ),
          ),
          const AdBanner(),
        ],
      ),
    );
  }
}

// ─── List ──────────────────────────────────────────────────────────────────

class _BlacklistList extends StatelessWidget {
  const _BlacklistList({
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  final List<BlacklistEntry> entries;
  final void Function(BlacklistEntry) onEdit;
  final void Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _AnimatedTile(
          index: index,
          child: _BlacklistTile(
            entry: entry,
            onEdit: () => onEdit(entry),
            onDelete: () => onDelete(entry.id),
          ),
        );
      },
    );
  }
}

class _AnimatedTile extends StatefulWidget {
  const _AnimatedTile({
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── Tile ──────────────────────────────────────────────────────────────────

class _BlacklistTile extends StatelessWidget {
  const _BlacklistTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final BlacklistEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _reasonColor(BlockReason reason) => switch (reason) {
        BlockReason.spam => AppColors.accentRed,
        BlockReason.telemarketing => AppColors.accentAmber,
        BlockReason.harassment => AppColors.accentPurple,
        BlockReason.other => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reasonLabel = switch (entry.reason) {
      BlockReason.spam => l10n.blacklistReasonSpam,
      BlockReason.telemarketing => l10n.blacklistReasonTelemarketing,
      BlockReason.harassment => l10n.blacklistReasonHarassment,
      BlockReason.other => l10n.blacklistReasonOther,
    };
    final color = _reasonColor(entry.reason);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: HarmonyCard(
        padding: AppSpacing.md,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.block_rounded, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GestureDetector(
                onTap: onEdit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.phoneNumber,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (entry.label != null && entry.label!.isNotEmpty)
                      Text(
                        entry.label!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    _ReasonBadge(label: reasonLabel, color: color),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.accentRed,
                size: 20,
              ),
              tooltip: 'Supprimer',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonBadge extends StatelessWidget {
  const _ReasonBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.accentGreen,
            size: 56,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.blacklistEmptyTitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
