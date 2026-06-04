import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../data/services/screen_time_limits_service.dart';
import '../../data/services/screen_time_summary_service.dart';

/// Écran de gestion des limites de temps d'écran (quota global + par app).
/// Accessible depuis [ScreenTimeSummaryScreen] via le FAB "Gérer les limites".
class ScreenTimeLimitsScreen extends StatefulWidget {
  const ScreenTimeLimitsScreen({
    super.key,
    required this.childId,
    this.childName,
  });

  final String childId;
  final String? childName;

  @override
  State<ScreenTimeLimitsScreen> createState() => _ScreenTimeLimitsScreenState();
}

class _ScreenTimeLimitsScreenState extends State<ScreenTimeLimitsScreen> {
  // Overridable in tests
  ScreenTimeLimitsService get _svc => ScreenTimeLimitsService.instance;
  ScreenTimeSummaryService get _summarySvc => ScreenTimeSummaryService.instance;

  List<ScreenTimeLimit>? _limits;
  List<ScreenTimeStatusEntry>? _statusEntries;
  ScreenTimeBonusEntry? _bonus;
  bool _loading = true;
  String? _error;
  bool _saving = false;

  ScreenTimeLimit? get _globalLimit =>
      _limits?.where((l) => l.scope == 'global').firstOrNull;

  List<ScreenTimeLimit> get _appLimits =>
      _limits?.where((l) => l.scope == 'app').toList() ?? [];

  ScreenTimeStatusEntry? _statusFor(String scope, String? packageName) {
    return _statusEntries?.where((s) {
      if (scope == 'global') return s.scope == 'global';
      return s.scope == 'app' && s.packageName == packageName;
    }).firstOrNull;
  }

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
      final limitsF = _svc.getLimits(widget.childId);
      final statusF = _svc.getStatus(widget.childId);
      final bonusF  = _svc.getBonus(widget.childId);
      final limits = await limitsF;
      List<ScreenTimeStatusEntry> status;
      try {
        status = await statusF;
      } catch (_) {
        // Pas d'usage pour aujourd'hui → statut indisponible, on continue
        status = [];
      }
      ScreenTimeBonusEntry? bonus;
      try {
        bonus = await bonusF;
      } catch (_) {
        // Bonus indisponible → on continue sans bonus
      }
      if (mounted) {
        setState(() {
          _limits = limits;
          _statusEntries = status;
          _bonus = bonus;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _saveGlobalLimit(int limitSeconds) async {
    setState(() => _saving = true);
    try {
      await _svc.setLimit(
        childId: widget.childId,
        scope: 'global',
        limitSeconds: limitSeconds,
      );
      await _load();
      if (mounted) _showSuccess('Quota global enregistré');
    } catch (e) {
      if (mounted) _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAppLimit(
    String packageName,
    String? appLabel,
    int limitSeconds,
  ) async {
    setState(() => _saving = true);
    try {
      await _svc.setLimit(
        childId: widget.childId,
        scope: 'app',
        limitSeconds: limitSeconds,
        packageName: packageName,
      );
      await _load();
      final name = appLabel ?? packageName.split('.').last;
      if (mounted) _showSuccess('Limite enregistrée pour $name');
    } catch (e) {
      if (mounted) _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Accorde ou ajuste le bonus du jour (en secondes absolues).
  Future<void> _saveBonus(int bonusSeconds) async {
    setState(() => _saving = true);
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      await _svc.setBonus(
        childId: widget.childId,
        bonusDate: dateStr,
        bonusSeconds: bonusSeconds,
      );
      await _load();
      if (mounted) {
        final msg = bonusSeconds == 0
            ? 'Bonus remis à zéro'
            : 'Bonus accordé : +${_formatDuration(bonusSeconds)}';
        _showSuccess(msg);
      }
    } catch (e) {
      if (mounted) _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteLimit(ScreenTimeLimit limit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDeleteDialog(
        label: limit.scope == 'global'
            ? 'le quota global'
            : (limit.appLabel ?? limit.packageName?.split('.').last ?? 'cette app'),
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await _svc.deleteLimit(limit.id);
      await _load();
      if (mounted) _showSuccess('Limite supprimée');
    } catch (e) {
      if (mounted) _showError('Erreur : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── Pickers ───────────────────────────────────────────────────────────────

  /// Ouvre le sélecteur de durée et retourne les secondes choisies, ou null si annulé.
  Future<int?> _pickDuration({int initialSeconds = 3600}) async {
    return showDialog<int>(
      context: context,
      builder: (_) => _DurationPickerDialog(initialSeconds: initialSeconds),
    );
  }

  /// Bottom sheet : apps vues aujourd'hui sans limite déjà définie.
  Future<void> _showAppPicker() async {
    ScreenTimeSummary? summary;
    try {
      summary = await _summarySvc.fetchSummary(widget.childId);
    } catch (_) {
      // Pas de données usage → liste vide
    }

    final existingPackages = _appLimits.map((l) => l.packageName).toSet();
    final available = (summary?.topApps ?? [])
        .where((a) => !existingPackages.contains(a.packageName))
        .toList();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AppPickerSheet(
        apps: available,
        onPick: (app) async {
          Navigator.of(ctx).pop();
          final seconds = await _pickDuration();
          if (seconds == null || !mounted) return;
          await _saveAppLimit(app.packageName, app.appLabel, seconds);
        },
      ),
    );
  }

  /// Ouvre le bottom sheet de temps bonus.
  Future<void> _showBonusSheet() async {
    final currentBonus = _bonus?.bonusSeconds ?? 0;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BonusSheet(
        currentBonusSeconds: currentBonus,
        onGrant: (increment) async {
          Navigator.of(context).pop();
          await _saveBonus(currentBonus + increment);
        },
        onReset: currentBonus > 0
            ? () async {
                Navigator.of(context).pop();
                await _saveBonus(0);
              }
            : null,
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title = widget.childName != null
        ? 'Limites — ${widget.childName}'
        : 'Limites de temps d\'écran';

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(title: title),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _load,
            color: AppColors.accentBlue,
            backgroundColor: AppColors.bgSurface,
            child: _buildBody(),
          ),
          if (_saving)
            const ColoredBox(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accentBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const _Skeleton();
    if (_error != null) return _ErrorView(onRetry: _load);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.md),
        _SectionLabel(label: 'QUOTA QUOTIDIEN GLOBAL'),
        const SizedBox(height: AppSpacing.sm),
        _GlobalQuotaCard(
          limit: _globalLimit,
          status: _globalLimit != null
              ? _statusFor('global', null)
              : null,
          bonusSeconds: _bonus?.bonusSeconds ?? 0,
          onSet: () async {
            final seconds =
                await _pickDuration(initialSeconds: _globalLimit?.limitSeconds ?? 3600);
            if (seconds != null) await _saveGlobalLimit(seconds);
          },
          onDelete: _globalLimit != null ? () => _deleteLimit(_globalLimit!) : null,
          onGrantBonus: _globalLimit != null ? _showBonusSheet : null,
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            const Expanded(child: _SectionLabel(label: 'LIMITES PAR APPLICATION')),
            TextButton.icon(
              onPressed: _showAppPicker,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(foregroundColor: AppColors.accentBlue),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_appLimits.isEmpty)
          const _EmptyAppsHint()
        else
          ..._appLimits.map((limit) => _AppLimitRow(
                limit: limit,
                status: _statusFor('app', limit.packageName),
                onEdit: () async {
                  final seconds =
                      await _pickDuration(initialSeconds: limit.limitSeconds);
                  if (seconds != null) {
                    await _saveAppLimit(
                      limit.packageName ?? '',
                      limit.appLabel,
                      seconds,
                    );
                  }
                },
                onDelete: () => _deleteLimit(limit),
              )),
        const SizedBox(height: AppSpacing.huge),
      ],
    );
  }
}

// ─── Widgets internes ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
      );
}

class _GlobalQuotaCard extends StatelessWidget {
  const _GlobalQuotaCard({
    required this.limit,
    required this.status,
    required this.onSet,
    this.onDelete,
    this.bonusSeconds = 0,
    this.onGrantBonus,
  });

  final ScreenTimeLimit? limit;
  final ScreenTimeStatusEntry? status;
  final int bonusSeconds;
  final VoidCallback onSet;
  final VoidCallback? onDelete;
  final VoidCallback? onGrantBonus;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: limit == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_off_outlined,
                        size: 20, color: AppColors.textMuted),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Aucun quota global défini',
                      style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSet,
                    icon: const Icon(Icons.add_alarm_outlined, size: 18),
                    label: const Text('Définir un quota quotidien'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentBlue,
                      side: const BorderSide(color: AppColors.accentBlue),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 20, color: AppColors.accentBlue),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _formatDuration(limit!.limitSeconds),
                        style: tt.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onSet,
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentBlue,
                          padding: EdgeInsets.zero),
                      child: const Text('Modifier'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.accentRed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (status != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _UsageBar(status: status!),
                ],
                const SizedBox(height: AppSpacing.md),
                // ─── Bonus du jour ────────────────────────────────────────
                if (bonusSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.accentGreen.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                size: 14,
                                color: AppColors.accentGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Bonus aujourd\'hui : +${_formatDuration(bonusSeconds)}',
                                style: tt.bodySmall?.copyWith(
                                  color: AppColors.accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onGrantBonus,
                    icon: const Icon(Icons.more_time_outlined, size: 16),
                    label: Text(
                      bonusSeconds > 0
                          ? 'Modifier le temps bonus'
                          : 'Accorder du temps bonus',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentGreen,
                      side: const BorderSide(color: AppColors.accentGreen),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      textStyle: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AppLimitRow extends StatelessWidget {
  const _AppLimitRow({
    required this.limit,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  final ScreenTimeLimit limit;
  final ScreenTimeStatusEntry? status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final label = limit.appLabel ?? limit.packageName?.split('.').last ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.bgInteractive,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apps_outlined,
                    size: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.sm),
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
                    Text(
                      _formatDuration(limit.limitSeconds),
                      style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentBlue,
                    padding: EdgeInsets.zero),
                child: const Text('Modifier'),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.accentRed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (status != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _UsageBar(status: status!),
          ],
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({required this.status});
  final ScreenTimeStatusEntry status;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    // Pour la limite globale, le bonus est inclus dans le quota effectif
    final effectiveLimit = status.limitSeconds + status.bonusSeconds;
    final ratio = effectiveLimit > 0
        ? (status.usedSeconds / effectiveLimit).clamp(0.0, 1.0)
        : 0.0;
    final color = status.exceeded ? AppColors.accentRed : AppColors.accentGreen;
    final label = status.exceeded
        ? 'Dépassé · ${_formatDuration(status.usedSeconds)} utilisées'
        : '${_formatDuration(status.usedSeconds)} / ${_formatDuration(effectiveLimit)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: AppColors.bgInteractive,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _EmptyAppsHint extends StatelessWidget {
  const _EmptyAppsHint();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Aucune limite par application. Appuyez sur "Ajouter" pour en créer une.',
              style: tt.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App picker (bottom sheet) ────────────────────────────────────────────────

class _AppPickerSheet extends StatelessWidget {
  const _AppPickerSheet({required this.apps, required this.onPick});
  final List<AppUsageEntry> apps;
  final ValueChanged<AppUsageEntry> onPick;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Choisir une application',
              style: tt.titleMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (apps.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'Aucune application vue aujourd\'hui, ou toutes ont déjà une limite.',
                style: tt.bodySmall?.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                itemCount: apps.length,
                itemBuilder: (_, i) {
                  final app = apps[i];
                  final label = app.appLabel ?? app.packageName.split('.').last;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.bgInteractive,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.apps_outlined,
                          size: 18, color: AppColors.textSecondary),
                    ),
                    title: Text(label,
                        style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary)),
                    subtitle: Text(
                      _formatDuration(app.durationSeconds),
                      style: tt.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                    onTap: () => onPick(app),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ─── Bonus sheet ─────────────────────────────────────────────────────────────

class _BonusSheet extends StatelessWidget {
  const _BonusSheet({
    required this.currentBonusSeconds,
    required this.onGrant,
    this.onReset,
  });

  final int currentBonusSeconds;
  final ValueChanged<int> onGrant;
  final VoidCallback? onReset;

  static const List<({int seconds, String label})> _presets = [
    (seconds: 900,  label: '+15 min'),
    (seconds: 1800, label: '+30 min'),
    (seconds: 3600, label: '+1 h'),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Temps bonus pour aujourd\'hui',
              style: tt.titleMedium?.copyWith(color: AppColors.textPrimary),
            ),
            if (currentBonusSeconds > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Bonus actuel : +${_formatDuration(currentBonusSeconds)}',
                style: tt.bodySmall?.copyWith(color: AppColors.accentGreen),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Ajouter au quota d\'aujourd\'hui :',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _presets
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: FilledButton(
                        onPressed: () => onGrant(p.seconds),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: Text(
                          p.label,
                          style: tt.bodySmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (onReset != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('Remettre le bonus à zéro'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentRed,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ─── Duration picker dialog ───────────────────────────────────────────────────

class _DurationPickerDialog extends StatefulWidget {
  const _DurationPickerDialog({this.initialSeconds = 3600});
  final int initialSeconds;

  @override
  State<_DurationPickerDialog> createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<_DurationPickerDialog> {
  static const List<int> _minuteOptions = [0, 5, 10, 15, 20, 30, 45];

  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialSeconds ~/ 3600;
    final rawMin = (widget.initialSeconds % 3600) ~/ 60;
    // Arrondi à l'option la plus proche
    _minutes = _minuteOptions.reduce(
      (a, b) => (b - rawMin).abs() < (a - rawMin).abs() ? b : a,
    );
    // Empêcher 0h 0min
    if (_hours == 0 && _minutes == 0) _minutes = 5;
  }

  int get _totalSeconds => _hours * 3600 + _minutes * 60;

  bool get _valid => _totalSeconds >= 300; // min 5 minutes

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      title: Text('Durée limite',
          style: tt.titleMedium?.copyWith(color: AppColors.textPrimary)),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heures
          DropdownButton<int>(
            value: _hours,
            dropdownColor: AppColors.bgElevated,
            style: tt.bodyLarge?.copyWith(color: AppColors.textPrimary),
            items: List.generate(
              13,
              (h) => DropdownMenuItem(
                value: h,
                child: Text('$h'),
              ),
            ),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _hours = v;
                if (_hours == 0 && _minutes == 0) _minutes = 5;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text('h',
                style: tt.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          ),
          // Minutes
          DropdownButton<int>(
            value: _minutes,
            dropdownColor: AppColors.bgElevated,
            style: tt.bodyLarge?.copyWith(color: AppColors.textPrimary),
            items: _minuteOptions
                .map(
                  (m) => DropdownMenuItem(
                    value: m,
                    child: Text(m.toString().padLeft(2, '0')),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _minutes = v;
                if (_hours == 0 && _minutes == 0) _minutes = 5;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text('min',
                style: tt.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: _valid ? () => Navigator.of(context).pop(_totalSeconds) : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            foregroundColor: AppColors.white,
          ),
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}

// ─── Confirmation suppression ─────────────────────────────────────────────────

class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      title: Text('Supprimer la limite',
          style: tt.titleMedium?.copyWith(color: AppColors.textPrimary)),
      content: Text(
        'Supprimer la limite pour $label ?',
        style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style:
              FilledButton.styleFrom(backgroundColor: AppColors.accentRed),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}

// ─── États loading / erreur ───────────────────────────────────────────────────

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        const _SkeletonBox(height: 24, width: 160),
        const SizedBox(height: AppSpacing.sm),
        const _SkeletonBox(height: 100),
        const SizedBox(height: AppSpacing.xl),
        const _SkeletonBox(height: 24, width: 200),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SkeletonBox(height: 72),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.width = double.infinity});
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.bgInteractive,
          borderRadius: BorderRadius.circular(12),
        ),
      );
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
            const Icon(Icons.wifi_off_outlined,
                size: 48, color: AppColors.accentAmber),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Impossible de charger les limites',
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

// ─── Helper durée ─────────────────────────────────────────────────────────────

String _formatDuration(int seconds) {
  if (seconds <= 0) return '0 min';
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}
