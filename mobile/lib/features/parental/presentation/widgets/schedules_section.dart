import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/services/schedule_api_service.dart';

// Noms courts des jours, indexés 1 (lundi) à 7 (dimanche)
const _dayLabels = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

/// Section "Horaires de coucher" affichée sur l'écran Détail de l'enfant.
/// Charge, crée et supprime des plages horaires via [ScheduleApiService].
class SchedulesSection extends StatefulWidget {
  const SchedulesSection({super.key, required this.childId});
  final String childId;

  @override
  State<SchedulesSection> createState() => _SchedulesSectionState();
}

class _SchedulesSectionState extends State<SchedulesSection> {
  final _service = ScheduleApiService.instance;

  List<ScheduleItem> _schedules = [];
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
      final items = await _service.getSchedules(widget.childId);
      if (mounted) setState(() => _schedules = items);
    } catch (e) {
      if (mounted) setState(() => _error = 'Impossible de charger les horaires.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(String scheduleId) async {
    try {
      await _service.deleteSchedule(scheduleId);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression.')),
        );
      }
    }
  }

  Future<void> _openAddForm() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ScheduleFormSheet(childId: widget.childId),
    );
    if (added == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête section
        Row(
          children: [
            Icon(Icons.bedtime_outlined, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'HORAIRES DE COUCHER',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _openAddForm,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Contenu
        if (_loading) ...[
          const Center(child: CircularProgressIndicator()),
        ] else if (_error != null) ...[
          Text(_error!, style: tt.bodySmall?.copyWith(color: AppColors.accentRed)),
        ] else if (_schedules.isEmpty) ...[
          Text(
            'Aucune plage configurée. Ajoute une heure de coucher.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ] else ...[
          for (final s in _schedules)
            _ScheduleTile(
              schedule: s,
              onDelete: () => _delete(s.id),
            ),
        ],
      ],
    );
  }
}

// ─── Tuile d'une plage ───────────────────────────────────────────────────────

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.schedule, required this.onDelete});
  final ScheduleItem schedule;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final daysText = schedule.daysOfWeek
        .map((d) => d >= 1 && d <= 7 ? _dayLabels[d] : '?')
        .join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          // Icône cadenas
          const Icon(Icons.lock_clock, size: 20, color: AppColors.accentAmber),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.label.isNotEmpty ? schedule.label : 'Plage sans nom',
                  style: tt.labelMedium?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  '${schedule.startTime} → ${schedule.endTime}  ·  $daysText',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.accentRed),
            onPressed: onDelete,
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }
}

// ─── Formulaire d'ajout (bottom sheet) ──────────────────────────────────────

class _ScheduleFormSheet extends StatefulWidget {
  const _ScheduleFormSheet({required this.childId});
  final String childId;

  @override
  State<_ScheduleFormSheet> createState() => _ScheduleFormSheetState();
}

class _ScheduleFormSheetState extends State<_ScheduleFormSheet> {
  final _labelController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);
  final Set<int> _selectedDays = {1, 2, 3, 4, 5}; // lun-ven par défaut
  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  Future<void> _save() async {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionne au moins un jour.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ScheduleApiService.instance.createSchedule(
        childId: widget.childId,
        label: _labelController.text.trim().isNotEmpty
            ? _labelController.text.trim()
            : 'Heure de coucher',
        startTime: _formatTime(_startTime),
        endTime: _formatTime(_endTime),
        daysOfWeek: _selectedDays.toList()..sort(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création de la plage.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text('Nouvelle plage de coucher', style: tt.titleMedium),
          const SizedBox(height: AppSpacing.lg),

          // Label
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Nom (ex : Heure de coucher)',
              border: OutlineInputBorder(borderRadius: AppRadius.mdRadius),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Heures
          Row(
            children: [
              Expanded(
                child: _TimePicker(
                  label: 'Début',
                  time: _startTime,
                  onTap: () => _pickTime(true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _TimePicker(
                  label: 'Fin',
                  time: _endTime,
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Indication traversée de minuit
          if (_startTime.hour * 60 + _startTime.minute >
              _endTime.hour * 60 + _endTime.minute) ...[
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Plage traversant minuit (ex : 21:00 → 07:00)',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Jours de la semaine
          Wrap(
            spacing: AppSpacing.xs,
            children: List.generate(7, (i) {
              final day = i + 1; // 1=lun..7=dim
              final selected = _selectedDays.contains(day);
              return FilterChip(
                label: Text(_dayLabels[day]),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _selectedDays.add(day);
                  } else {
                    _selectedDays.remove(day);
                  }
                }),
                selectedColor: AppColors.accentBlue.withValues(alpha: 0.2),
                checkmarkColor: AppColors.accentBlue,
                labelStyle: tt.bodySmall?.copyWith(
                  color: selected ? AppColors.accentBlue : cs.onSurfaceVariant,
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Bouton enregistrer
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget sélecteur d'heure ─────────────────────────────────────────────

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  String _format(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: AppRadius.mdRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.accentBlue),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _format(time),
                  style: tt.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
