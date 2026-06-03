import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../data/services/screen_time_summary_service.dart';

/// Écran "Temps d'écran" du parent — affiche le résumé d'usage d'un enfant pour aujourd'hui.
/// Accessible depuis [ChildDetailScreen] → bouton "Temps d'écran".
class ScreenTimeSummaryScreen extends StatefulWidget {
  const ScreenTimeSummaryScreen({
    super.key,
    required this.childId,
    this.childName,
  });

  final String childId;
  final String? childName;

  @override
  State<ScreenTimeSummaryScreen> createState() => _ScreenTimeSummaryScreenState();
}

class _ScreenTimeSummaryScreenState extends State<ScreenTimeSummaryScreen> {
  ScreenTimeSummary? _summary;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await ScreenTimeSummaryService.instance
          .fetchSummary(widget.childId);
      if (mounted) setState(() => _summary = summary);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.childName != null
        ? 'Temps d\'écran — ${widget.childName}'
        : 'Temps d\'écran';

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(title: title),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '${RouteNames.childDetail}/${widget.childId}/screen-time/limits'
          '${widget.childName != null ? '?name=${Uri.encodeComponent(widget.childName!)}' : ''}',
        ),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.timer_outlined),
        label: const Text('Gérer les limites'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.accentBlue,
        backgroundColor: AppColors.bgSurface,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const _Skeleton();
    if (_error != null) return _ErrorView(onRetry: _load);
    final summary = _summary;
    if (summary == null || summary.totalSeconds == 0) return _EmptyView();
    return _SummaryView(summary: summary);
  }
}

// ─── Vue principale ──────────────────────────────────────────────────────────

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.summary});
  final ScreenTimeSummary summary;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.md),

        // Total du jour
        _TotalCard(totalSeconds: summary.totalSeconds, usageDate: summary.usageDate),
        const SizedBox(height: AppSpacing.xl),

        // Top apps
        Text(
          'APPLICATIONS',
          style: tt.labelSmall?.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...summary.topApps.map(
          (app) => _AppRow(app: app, totalSeconds: summary.totalSeconds),
        ),

        // Catégories (si disponibles)
        if (summary.totalByCategory.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'PAR CATÉGORIE',
            style: tt.labelSmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CategoriesCard(totalByCategory: summary.totalByCategory),
        ],

        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

// ─── Carte total journalier ───────────────────────────────────────────────────

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.totalSeconds, required this.usageDate});
  final int totalSeconds;
  final String usageDate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Text(
            _formatDuration(totalSeconds),
            style: AppTypography.textTheme.displayMedium?.copyWith(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'utilisés aujourd\'hui',
            style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            usageDate,
            style: tt.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Ligne par application ───────────────────────────────────────────────────

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app, required this.totalSeconds});
  final AppUsageEntry app;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final ratio = totalSeconds > 0 ? app.durationSeconds / totalSeconds : 0.0;
    final label = app.appLabel ?? app.packageName.split('.').last;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icône placeholder basé sur la catégorie
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bgInteractive,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _categoryIcon(app.category),
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: tt.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (app.category != null)
                      Text(
                        app.category!,
                        style: tt.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatDuration(app.durationSeconds),
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Barre de progression proportionnelle au total
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.bgInteractive,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String? category) => switch (category) {
        'social'       => Icons.people_outline,
        'games'        => Icons.videogame_asset_outlined,
        'video'        => Icons.play_circle_outline,
        'music'        => Icons.music_note_outlined,
        'news'         => Icons.article_outlined,
        'maps'         => Icons.map_outlined,
        'productivity' => Icons.work_outline,
        'photo'        => Icons.photo_outlined,
        _              => Icons.apps_outlined,
      };
}

// ─── Carte catégories ────────────────────────────────────────────────────────

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({required this.totalByCategory});
  final Map<String, int> totalByCategory;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final sorted = totalByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: sorted
            .map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    Text(
                      _formatDuration(e.value),
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── États vide / erreur / skeleton ─────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucune donnée d\'usage pour le moment',
              style: tt.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'L\'app enfant doit être active et la permission de suivi accordée.',
              style: tt.bodySmall?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.accentAmber),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Impossible de charger les données',
              style: tt.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const _SkeletonBox(height: 120, radius: 20),
        const SizedBox(height: AppSpacing.xl),
        ...List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: _SkeletonBox(height: 56),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.radius = 12.0});
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bgInteractive,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

// ─── Helper formatage durée ───────────────────────────────────────────────────

String _formatDuration(int seconds) {
  if (seconds <= 0) return '0 min';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}
