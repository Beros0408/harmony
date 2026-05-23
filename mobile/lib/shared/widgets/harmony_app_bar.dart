import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class HarmonyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HarmonyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showGradient = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showGradient;

  @override
  // +1 pour la bordure inférieure déclarée dans bottom
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          showGradient ? null : Colors.transparent,
      flexibleSpace: showGradient
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x1A3B82F6),
                    Colors.transparent,
                  ],
                ),
              ),
            )
          : null,
      leading: leading,
      title: Row(
        children: [
          Text(
            title,
            style: AppTypography.textTheme.titleLarge,
          ),
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderSubtle,
        ),
      ),
    );
  }
}
