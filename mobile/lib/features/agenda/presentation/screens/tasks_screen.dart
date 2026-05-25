import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';
import '../../../../shared/widgets/harmony_text_field.dart';
import '../../data/models/task_item.dart';
import '../../logic/task_cubit.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(title: l10n.agendaTasksTitle),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state.status == TaskStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentBlue,
                strokeWidth: 2,
              ),
            );
          }

          final quadrantMap = state.byQuadrant;
          final hasAny = quadrantMap.values.any((l) => l.isNotEmpty);

          if (!hasAny) {
            return HarmonyEmptyState(
              icon: Icons.checklist_outlined,
              title: l10n.agendaTasksEmpty,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Grille Eisenhower 2×2
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _QuadrantCard(
                            title: l10n.agendaTasksQuadrantDoFirst,
                            quadrant: EisenhowerQuadrant.doFirst,
                            color: AppColors.accentRed,
                            tasks: quadrantMap[EisenhowerQuadrant.doFirst]!,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _QuadrantCard(
                            title: l10n.agendaTasksQuadrantDelegate,
                            quadrant: EisenhowerQuadrant.delegate,
                            color: AppColors.accentAmber,
                            tasks: quadrantMap[EisenhowerQuadrant.delegate]!,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        children: [
                          _QuadrantCard(
                            title: l10n.agendaTasksQuadrantSchedule,
                            quadrant: EisenhowerQuadrant.schedule,
                            color: AppColors.accentBlue,
                            tasks: quadrantMap[EisenhowerQuadrant.schedule]!,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _QuadrantCard(
                            title: l10n.agendaTasksQuadrantDelete,
                            quadrant: EisenhowerQuadrant.delete,
                            color: AppColors.textMuted,
                            tasks: quadrantMap[EisenhowerQuadrant.delete]!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: AppColors.textInverse,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTaskSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TaskCubit>(),
        child: const _AddTaskSheet(),
      ),
    );
  }
}

// ─── Quadrant card ────────────────────────────────────────────────────────────

class _QuadrantCard extends StatelessWidget {
  const _QuadrantCard({
    required this.title,
    required this.quadrant,
    required this.color,
    required this.tasks,
  });

  final String title;
  final EisenhowerQuadrant quadrant;
  final Color color;
  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.mdRadius,
        border: Border(top: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.labelSmall?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                '—',
                style: AppTypography.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
            )
          else
            ...tasks.map(
              (task) => _TaskRow(task: task, quadrantColor: color),
            ),
        ],
      ),
    );
  }
}

// ─── Task row ─────────────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.quadrantColor});
  final TaskItem task;
  final Color quadrantColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<TaskCubit>().toggleComplete(task.id),
            child: Icon(
              task.completed
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              size: 18,
              color: task.completed ? AppColors.accentGreen : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              task.title,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                decoration:
                    task.completed ? TextDecoration.lineThrough : null,
                color: task.completed
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => context.read<TaskCubit>().deleteTask(task.id),
            child: const Icon(
              Icons.close,
              size: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add task bottom sheet ────────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _ctrl = TextEditingController();
  TaskUrgency _urgency = TaskUrgency.medium;
  TaskImportance _importance = TaskImportance.medium;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: mediaQuery.viewInsets.bottom + AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.agendaTasksAdd, style: AppTypography.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          HarmonyTextField(controller: _ctrl, label: l10n.agendaEditorFieldTitle),
          const SizedBox(height: AppSpacing.md),
          // Urgence
          _EnumSelector<TaskUrgency>(
            label: 'Urgence',
            values: TaskUrgency.values,
            selected: _urgency,
            labelOf: (u) => switch (u) {
              TaskUrgency.low => 'Faible',
              TaskUrgency.medium => 'Moyenne',
              TaskUrgency.high => 'Haute',
            },
            onChanged: (v) => setState(() => _urgency = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Importance
          _EnumSelector<TaskImportance>(
            label: 'Importance',
            values: TaskImportance.values,
            selected: _importance,
            labelOf: (i) => switch (i) {
              TaskImportance.low => 'Faible',
              TaskImportance.medium => 'Moyenne',
              TaskImportance.high => 'Haute',
            },
            onChanged: (v) => setState(() => _importance = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _add,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: AppColors.textInverse,
              ),
              child: Text(l10n.agendaTasksAdd),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;

    final task = TaskItem(
      id: const Uuid().v4(),
      title: title,
      urgency: _urgency,
      importance: _importance,
    );

    await context.read<TaskCubit>().addTask(task);
    if (mounted) Navigator.pop(context);
  }
}

class _EnumSelector<T> extends StatelessWidget {
  const _EnumSelector({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: AppTypography.textTheme.labelSmall
                  ?.copyWith(color: AppColors.textSecondary),),
        ),
        ...values.map((v) {
          final isSelected = v == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: GestureDetector(
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4,),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentBlue.withValues(alpha: 0.2)
                      : AppColors.bgSurface,
                  borderRadius: AppRadius.smRadius,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentBlue
                        : AppColors.borderDefault,
                  ),
                ),
                child: Text(
                  labelOf(v),
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? AppColors.accentBlue
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
