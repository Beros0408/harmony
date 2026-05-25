import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_text_field.dart';
import '../../data/models/agenda_event.dart';
import '../../logic/agenda_event_cubit.dart';
import '../widgets/category_chip.dart';

class EventEditorScreen extends StatefulWidget {
  const EventEditorScreen({super.key, this.eventId});

  // null → nouvel événement ; non-null → édition
  final String? eventId;

  @override
  State<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends State<EventEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;

  late DateTime _startDate;
  late DateTime _endDate;
  late EventCategory _category;
  late int _reminderMinutes;
  late bool _important;
  late Color _color;

  AgendaEvent? _original;

  @override
  void initState() {
    super.initState();

    // Si édition, charge l'événement depuis le state
    if (widget.eventId != null) {
      final eventState = context.read<AgendaEventCubit>().state;
      _original = eventState.events
          .where((e) => e.id == widget.eventId)
          .cast<AgendaEvent?>()
          .firstOrNull;
    }

    final src = _original;
    if (src != null) {
      _titleCtrl = TextEditingController(text: src.title);
      _descCtrl = TextEditingController(text: src.description);
      _locationCtrl = TextEditingController(text: src.location ?? '');
      _startDate = src.startDate;
      _endDate = src.endDate;
      _category = src.category;
      _reminderMinutes = src.reminderMinutesBefore;
      _important = src.important;
      _color = src.color;
    } else {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day, now.hour + 1);
      _titleCtrl = TextEditingController();
      _descCtrl = TextEditingController();
      _locationCtrl = TextEditingController();
      _startDate = start;
      _endDate = start.add(const Duration(hours: 1));
      _category = EventCategory.other;
      _reminderMinutes = 30;
      _important = false;
      _color = categoryColor(EventCategory.other);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNew = _original == null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: isNew ? l10n.agendaEditorNewTitle : l10n.agendaEditorEditTitle,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Titre
            HarmonyTextField(
              controller: _titleCtrl,
              label: l10n.agendaEditorFieldTitle,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.agendaEditorValidationTitle : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Description (multiline — HarmonyTextField est 1 ligne, on utilise TextFormField directement)
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(labelText: l10n.agendaEditorFieldDescription),
            ),
            const SizedBox(height: AppSpacing.md),

            // Lieu
            HarmonyTextField(
              controller: _locationCtrl,
              label: l10n.agendaEditorFieldLocation,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Catégorie
            _SectionLabel(l10n.agendaEditorFieldCategory),
            const SizedBox(height: AppSpacing.sm),
            _CategorySelector(
              selected: _category,
              onChanged: (cat) => setState(() {
                _category = cat;
                _color = categoryColor(cat);
              }),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Dates
            _SectionLabel(l10n.agendaEditorFieldStart),
            const SizedBox(height: AppSpacing.sm),
            _DateTimePicker(
              value: _startDate,
              onChanged: (dt) => setState(() {
                _startDate = dt;
                if (_endDate.isBefore(dt)) {
                  _endDate = dt.add(const Duration(hours: 1));
                }
              }),
            ),
            const SizedBox(height: AppSpacing.md),

            _SectionLabel(l10n.agendaEditorFieldEnd),
            const SizedBox(height: AppSpacing.sm),
            _DateTimePicker(
              value: _endDate,
              onChanged: (dt) => setState(() => _endDate = dt),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Rappel
            _SectionLabel(l10n.agendaEditorFieldReminder),
            const SizedBox(height: AppSpacing.sm),
            _ReminderSelector(
              value: _reminderMinutes,
              onChanged: (v) => setState(() => _reminderMinutes = v),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Important
            _ImportantToggle(
              value: _important,
              label: l10n.agendaEditorMarkImportant,
              onChanged: (v) => setState(() => _important = v),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Bouton enregistrer
            HarmonyButton(
              label: l10n.agendaEditorSave,
              icon: Icons.check_rounded,
              onPressed: _save,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final event = AgendaEvent(
      id: _original?.id ?? const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      startDate: _startDate,
      endDate: _endDate,
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      reminderMinutesBefore: _reminderMinutes,
      important: _important,
      color: _color,
      googleEventId: _original?.googleEventId,
      familyMemberIds: _original?.familyMemberIds ?? const [],
    );

    final cubit = context.read<AgendaEventCubit>();
    if (_original == null) {
      await cubit.addEvent(event);
    } else {
      await cubit.updateEvent(event);
    }

    if (mounted) context.pop();
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      );
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.selected, required this.onChanged});
  final EventCategory selected;
  final ValueChanged<EventCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: EventCategory.values.map((cat) {
        final isSelected = cat == selected;
        final color = categoryColor(cat);
        return GestureDetector(
          onTap: () => onChanged(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.2) : cs.surface,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(
                color: isSelected ? color : cs.outline,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: CategoryChip(category: cat),
          ),
        );
      }).toList(),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({required this.value, required this.onChanged});
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final fmt = DateFormat('EEE d MMM yyyy · HH:mm', locale);
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.mdRadius,
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_outlined,
                size: 18, color: cs.onSurfaceVariant,),
            const SizedBox(width: AppSpacing.sm),
            Text(
              fmt.format(value),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (time == null) return;

    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

class _ReminderSelector extends StatelessWidget {
  const _ReminderSelector({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  static const _options = [5, 10, 15, 30, 60, 120];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      children: _options.map((mins) {
        final isSelected = mins == value;
        final label = mins < 60 ? '$mins min' : '${mins ~/ 60}h';
        return ChoiceChip(
          label: Text(label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : cs.onSurfaceVariant,
              ),),
          selected: isSelected,
          onSelected: (_) => onChanged(mins),
          selectedColor: AppColors.accentBlue,
          backgroundColor: cs.surface,
          side: BorderSide(
            color: isSelected ? AppColors.accentBlue : cs.outline,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        );
      }).toList(),
    );
  }
}

class _ImportantToggle extends StatelessWidget {
  const _ImportantToggle({
    required this.value,
    required this.label,
    required this.onChanged,
  });
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: value
                ? AppColors.accentAmber.withValues(alpha: 0.4)
                : cs.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.star_rounded : Icons.star_outline_rounded,
              color: value ? AppColors.accentAmber : cs.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.accentAmber,
            ),
          ],
        ),
      ),
    );
  }
}
