import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/models/agenda_event.dart';
import 'category_chip.dart';

class EventListTile extends StatelessWidget {
  const EventListTile({
    super.key,
    required this.event,
    this.onTap,
  });

  final AgendaEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm(Localizations.localeOf(context).languageCode);
    final startStr = timeFormat.format(event.startDate);
    final endStr = timeFormat.format(event.endDate);
    final color = event.color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Barre colorée catégorie
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppRadius.lg),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      // Heure
                      SizedBox(
                        width: 52,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              startStr,
                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              endStr,
                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Contenu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              event.title,
                              style: AppTypography.textTheme.labelMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (event.location != null &&
                                event.location!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 11,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      event.location!,
                                      style:
                                          AppTypography.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Badges droite
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CategoryChip(category: event.category, compact: true),
                          if (event.important) ...[
                            const SizedBox(height: 3),
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.accentAmber,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
