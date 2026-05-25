import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';
import '../../data/models/agenda_event.dart';
import '../../logic/agenda_event_cubit.dart';
import '../../logic/calendar_view_cubit.dart';
import '../widgets/event_list_tile.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<AgendaEventCubit>().loadEventsForMonth(now);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(
        title: l10n.agendaScreenTitle,
        actions: [
          // Raccourci tâches
          IconButton(
            tooltip: l10n.agendaTasksShortcut,
            icon: const Icon(Icons.checklist_rounded, color: AppColors.textSecondary),
            onPressed: () => context.push(RouteNames.agendaTasks),
          ),
          // Raccourci Google Calendar
          IconButton(
            tooltip: l10n.agendaGoogleShortcut,
            icon: const Icon(Icons.sync_rounded, color: AppColors.textSecondary),
            onPressed: () => context.push(RouteNames.agendaGoogle),
          ),
        ],
      ),
      body: Column(
        children: [
          _CalendarSection(),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Expanded(child: _EventsSection()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.agendaEventEdit),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: AppColors.textInverse,
        icon: const Icon(Icons.add),
        label: Text(l10n.agendaCreateButton, style: AppTypography.textTheme.labelLarge),
      ),
    );
  }
}

// ─── Calendrier ──────────────────────────────────────────────────────────────

class _CalendarSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarViewCubit, CalendarViewState>(
      builder: (context, viewState) {
        return BlocBuilder<AgendaEventCubit, AgendaEventState>(
          builder: (context, eventState) {
            return TableCalendar<AgendaEvent>(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2035),
              focusedDay: viewState.focusedDay,
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) =>
                  isSameDay(viewState.selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                context.read<CalendarViewCubit>().selectDay(selectedDay);
              },
              onPageChanged: (focusedDay) {
                context.read<CalendarViewCubit>().setFocusedDay(focusedDay);
                context
                    .read<AgendaEventCubit>()
                    .loadEventsForMonth(focusedDay);
              },
              eventLoader: (day) => eventState.eventsForDay(day),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: AppTypography.textTheme.bodyMedium!
                    .copyWith(color: AppColors.textPrimary),
                weekendTextStyle: AppTypography.textTheme.bodyMedium!
                    .copyWith(color: AppColors.textSecondary),
                outsideTextStyle: AppTypography.textTheme.bodyMedium!
                    .copyWith(color: AppColors.textMuted),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.accentBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accentBlue),
                ),
                todayTextStyle: AppTypography.textTheme.bodyMedium!
                    .copyWith(color: AppColors.accentBlue),
                markerDecoration: const BoxDecoration(
                  color: AppColors.accentAmber,
                  shape: BoxShape.circle,
                ),
                markerSize: 5,
                markersMaxCount: 3,
                tableBorder: const TableBorder(),
                cellMargin: const EdgeInsets.all(4),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTypography.textTheme.titleSmall!,
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.textSecondary,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
                headerPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTypography.textTheme.labelSmall!
                    .copyWith(color: AppColors.textMuted),
                weekendStyle: AppTypography.textTheme.labelSmall!
                    .copyWith(color: AppColors.textMuted),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Événements du jour sélectionné ──────────────────────────────────────────

class _EventsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<CalendarViewCubit, CalendarViewState>(
      builder: (context, viewState) {
        return BlocBuilder<AgendaEventCubit, AgendaEventState>(
          builder: (context, eventState) {
            if (eventState.status == AgendaEventStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentBlue,
                  strokeWidth: 2,
                ),
              );
            }

            final events = eventState.eventsForDay(viewState.selectedDay);

            if (events.isEmpty) {
              return HarmonyEmptyState(
                icon: Icons.event_available_outlined,
                title: l10n.agendaNoEvents,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                100,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventListTile(
                  event: event,
                  onTap: () => context.push(
                    '${RouteNames.agendaEvent}/${event.id}',
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
