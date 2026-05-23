import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum HarmonyButtonVariant { primary, secondary, danger, ghost }

enum HarmonyButtonSize { sm, md, lg }

class HarmonyButton extends StatefulWidget {
  const HarmonyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = HarmonyButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = HarmonyButtonSize.md,
  });

  final String label;
  final VoidCallback? onPressed;
  final HarmonyButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final HarmonyButtonSize size;

  @override
  State<HarmonyButton> createState() => _HarmonyButtonState();
}

class _HarmonyButtonState extends State<HarmonyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  bool get _isInteractive => !widget.isDisabled && !widget.isLoading;

  void _onHoverChanged(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _scaleController.forward();
    } else {
      _scaleController.reverse();
    }
  }

  // Dimensions selon la taille
  EdgeInsets get _padding => switch (widget.size) {
        HarmonyButtonSize.sm => const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        HarmonyButtonSize.md => const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
        HarmonyButtonSize.lg => const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
      };

  TextStyle? get _textStyle => switch (widget.size) {
        HarmonyButtonSize.sm => AppTypography.textTheme.labelMedium,
        HarmonyButtonSize.md => AppTypography.textTheme.labelLarge,
        HarmonyButtonSize.lg => AppTypography.textTheme.labelLarge?.copyWith(
            fontSize: 16,
          ),
      };

  // Couleurs selon le variant
  Color get _backgroundColor => switch (widget.variant) {
        HarmonyButtonVariant.primary =>
          _isHovered ? AppColors.accentBlueHover : AppColors.accentBlue,
        HarmonyButtonVariant.secondary => AppColors.bgElevated,
        HarmonyButtonVariant.danger => AppColors.accentRed.withValues(alpha: 0.12),
        HarmonyButtonVariant.ghost => Colors.transparent,
      };

  Color get _foregroundColor => switch (widget.variant) {
        HarmonyButtonVariant.primary => Colors.white,
        HarmonyButtonVariant.secondary => AppColors.textPrimary,
        HarmonyButtonVariant.danger => AppColors.accentRed,
        HarmonyButtonVariant.ghost => AppColors.textSecondary,
      };

  Border? get _border => switch (widget.variant) {
        HarmonyButtonVariant.secondary => Border.all(
            color: AppColors.borderDefault,
          ),
        HarmonyButtonVariant.ghost => Border.all(
            color: Colors.transparent,
          ),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = _isInteractive ? 1.0 : 0.4;

    return MouseRegion(
      onEnter: _isInteractive ? (_) => _onHoverChanged(true) : null,
      onExit: _isInteractive ? (_) => _onHoverChanged(false) : null,
      cursor: _isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: effectiveOpacity,
          child: GestureDetector(
            onTap: _isInteractive ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: _padding,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: AppRadius.mdRadius,
                border: _border,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _foregroundColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: _foregroundColor, size: 16),
                          const SizedBox(width: AppSpacing.xs),
                        ],
                        Text(
                          widget.label,
                          style: _textStyle?.copyWith(color: _foregroundColor),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
