import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_snack_bar.dart';
import '../../data/models/agenda_event.dart';
import '../../logic/agenda_event_cubit.dart';
import '../widgets/category_chip.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AgendaEventCubit, AgendaEventState>(
      builder: (context, state) {
        // Recherche l'événement dans le state courant
        final event = state.events
            .where((e) => e.id == eventId)
            .cast<AgendaEvent?>()
            .firstOrNull;

        if (event == null) {
          return Scaffold(
            backgroundColor: AppColors.bgBase,
            appBar: HarmonyAppBar(title: l10n.agendaEventDetailTitle),
            body: Center(
              child: Text(
                l10n.emptyStateComingSoon,
                style: AppTypography.textTheme.bodyMedium,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.bgBase,
          appBar: HarmonyAppBar(
            title: l10n.agendaEventDetailTitle,
            actions: [
              // Modifier
              IconButton(
                tooltip: l10n.agendaEventEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                onPressed: () =>
                    context.push('${RouteNames.agendaEventEdit}/${event.id}'),
              ),
              // Important
              IconButton(
                tooltip: l10n.agendaEventImportant,
                icon: Icon(
                  event.important ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: event.important
                      ? AppColors.accentAmber
                      : AppColors.textMuted,
                ),
                onPressed: () {
                  context.read<AgendaEventCubit>().markImportant(
                        event,
                        important: !event.important,
                      );
                },
              ),
              // Supprimer
              IconButton(
                tooltip: l10n.agendaEventDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.accentRed,),
                onPressed: () => _confirmDelete(context, l10n, event),
              ),
            ],
          ),
          body: _EventDetailBody(event: event),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    AgendaEvent event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: Text(l10n.agendaEventDelete,
            style: AppTypography.textTheme.titleSmall,),
        content: Text(l10n.agendaEventDeleteConfirm,
            style: AppTypography.textTheme.bodyMedium,),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.agendaEventDeleteConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.agendaEventDeleteConfirmYes,
                style: const TextStyle(color: AppColors.accentRed),),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AgendaEventCubit>().deleteEvent(event.id);
      if (context.mounted) {
        HarmonySnackBar.show(context, message: l10n.agendaEventDeleteConfirmYes);
        context.pop();
      }
    }
  }
}

class _EventDetailBody extends StatelessWidget {
  const _EventDetailBody({required this.event});
  final AgendaEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dtFmt = DateFormat('EEEE d MMMM yyyy · HH:mm', locale);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Barre couleur + titre
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: AppRadius.lgRadius,
            border: Border(
              left: BorderSide(color: event.color, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryChip(category: event.category),
                  if (event.important) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.star_rounded,
                        size: 16, color: AppColors.accentAmber,),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(event.title, style: AppTypography.textTheme.titleMedium),
              if (event.description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(event.description,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Détails
        _DetailRow(
          icon: Icons.schedule_outlined,
          label: dtFmt.format(event.startDate),
          sublabel:
              '→ ${DateFormat('HH:mm', locale).format(event.endDate)}',
        ),
        if (event.location != null && event.location!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: l10n.agendaEventLocation,
            sublabel: event.location!,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _DetailRow(
          icon: Icons.notifications_outlined,
          label: l10n.agendaEventReminder,
          sublabel: l10n.agendaEventReminderMinutes(event.reminderMinutesBefore),
        ),
        if (event.recurrenceRule != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            icon: Icons.repeat_rounded,
            label: l10n.agendaEventRecurrence,
            sublabel: event.recurrenceRule!,
          ),
        ],
        if (event.googleEventId != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            icon: Icons.sync_rounded,
            label: 'Google Calendar',
            sublabel: event.googleEventId!,
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(sublabel,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),),
            ],
          ),
        ),
      ],
    );
  }
}
