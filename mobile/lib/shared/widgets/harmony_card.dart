import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class HarmonyCard extends StatelessWidget {
  const HarmonyCard({
    super.key,
    required this.child,
    this.title,
    this.badge,
    this.action,
    this.padding = AppSpacing.xl,
    this.onTap,
  });

  final Widget child;
  final String? title;
  final Widget? badge;
  final Widget? action;
  final double padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: AppColors.borderDefault),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || badge != null || action != null)
              Padding(
                padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: AppTypography.textTheme.titleSmall,
                        ),
                      ),
                    if (badge != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      badge!,
                    ],
                    if (action != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      action!,
                    ],
                  ],
                ),
              ),
            Padding(
              padding: title != null || badge != null || action != null
                  ? EdgeInsets.fromLTRB(padding, AppSpacing.md, padding, padding)
                  : EdgeInsets.all(padding),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
