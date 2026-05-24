import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class HarmonyCard extends StatefulWidget {
  const HarmonyCard({
    super.key,
    required this.child,
    this.title,
    this.badge,
    this.action,
    this.padding = 14.0,
    this.onTap,
  });

  final Widget child;
  final String? title;
  final Widget? badge;
  final Widget? action;
  final double padding;
  final VoidCallback? onTap;

  @override
  State<HarmonyCard> createState() => _HarmonyCardState();
}

class _HarmonyCardState extends State<HarmonyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDark
        ? const Color(0x66000000)
        : const Color(0x18000000);
    final hasHeader = widget.title != null || widget.badge != null || widget.action != null;

    Widget card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasHeader)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      widget.padding,
                      widget.padding,
                      widget.padding,
                      0,
                    ),
                    child: Row(
                      children: [
                        if (widget.title != null)
                          Expanded(
                            child: Text(
                              widget.title!,
                              style: AppTypography.textTheme.titleSmall,
                            ),
                          ),
                        if (widget.badge != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          widget.badge!,
                        ],
                        if (widget.action != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          widget.action!,
                        ],
                      ],
                    ),
                  ),
                Padding(
                  padding: hasHeader
                      ? EdgeInsets.fromLTRB(
                          widget.padding,
                          AppSpacing.md,
                          widget.padding,
                          widget.padding,
                        )
                      : EdgeInsets.all(widget.padding),
                  child: widget.child,
                ),
              ],
            ),
          ),
          // Luminous border-top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.accentBlue.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.onTap == null) return card;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: card,
        ),
      ),
    );
  }
}
