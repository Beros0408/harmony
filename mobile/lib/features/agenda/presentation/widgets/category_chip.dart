import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/agenda_event.dart';
import '../../../../l10n/app_localizations.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category, this.compact = false});

  final EventCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = categoryColor(category);
    final label = _label(category, l10n);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }

  String _label(EventCategory cat, AppLocalizations l10n) => switch (cat) {
        EventCategory.sport => l10n.agendaCategorySport,
        EventCategory.medical => l10n.agendaCategoryMedical,
        EventCategory.professional => l10n.agendaCategoryProfessional,
        EventCategory.school => l10n.agendaCategorySchool,
        EventCategory.leisure => l10n.agendaCategoryLeisure,
        EventCategory.other => l10n.agendaCategoryOther,
      };
}
