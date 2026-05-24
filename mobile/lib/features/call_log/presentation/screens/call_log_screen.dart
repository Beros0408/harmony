import 'package:flutter/material.dart';
import 'package:harmony/core/constants/app_colors.dart';
import 'package:harmony/core/constants/app_spacing.dart';
import 'package:harmony/features/call_filter/data/native/call_filter_channel.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/widgets/harmony_app_bar.dart';
import 'package:harmony/shared/widgets/harmony_card.dart';
import 'package:intl/intl.dart';

enum _LogFilter { today, week, all }

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({super.key});

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<BlockedCallEntry> _allCalls = [];
  _LogFilter _filter = _LogFilter.today;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCalls();
  }

  Future<void> _loadCalls() async {
    final calls = await CallFilterChannel.getBlockedCalls();
    if (mounted) setState(() { _allCalls = calls; _loading = false; });
  }

  Future<void> _clearAll() async {
    await CallFilterChannel.clearBlockedCalls();
    if (mounted) setState(() => _allCalls = []);
  }

  List<BlockedCallEntry> get _filtered {
    final now = DateTime.now();
    return switch (_filter) {
      _LogFilter.today => _allCalls.where((c) {
          final d = c.timestamp;
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList(),
      _LogFilter.week => _allCalls.where((c) {
          return now.difference(c.timestamp).inDays < 7;
        }).toList(),
      _LogFilter.all => _allCalls,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: l10n.callLogScreenTitle,
        actions: [
          if (_allCalls.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: Text(
                l10n.callLogClearAllButton,
                style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            current: _filter,
            l10n: l10n,
            onChanged: (f) => setState(() => _filter = f),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? _EmptyState(label: l10n.callLogEmptyState)
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _CallLogTile(entry: _filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.current,
    required this.l10n,
    required this.onChanged,
  });
  final _LogFilter current;
  final AppLocalizations l10n;
  final ValueChanged<_LogFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = [
      (_LogFilter.today, l10n.callLogFilterToday),
      (_LogFilter.week, l10n.callLogFilterWeek),
      (_LogFilter.all, l10n.callLogFilterAll),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: filters
            .map(
              (f) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(f.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: current == f.$1
                          ? AppColors.accentBlue.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: current == f.$1
                            ? AppColors.accentBlue
                            : AppColors.borderDefault,
                      ),
                    ),
                    child: Text(
                      f.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: current == f.$1
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: current == f.$1
                            ? AppColors.accentBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CallLogTile extends StatelessWidget {
  const _CallLogTile({required this.entry});
  final BlockedCallEntry entry;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('dd/MM  HH:mm').format(entry.timestamp);
    return HarmonyCard(
      padding: AppSpacing.md,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentRed.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.block_rounded,
              color: AppColors.accentRed,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.phoneNumber.isEmpty ? '—' : entry.phoneNumber,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.latencyMs}ms',
              style: const TextStyle(
                fontFamily: 'GeistMono',
                fontSize: 11,
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.accentGreen, size: 48),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
