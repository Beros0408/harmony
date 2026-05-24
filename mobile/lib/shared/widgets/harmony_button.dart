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
  late AnimationController _hoverController;
  late Animation<double> _hoverScale;
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _hoverScale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isInteractive => !widget.isDisabled && !widget.isLoading;

  void _onHoverChanged(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  EdgeInsets get _padding => switch (widget.size) {
        HarmonyButtonSize.sm => const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        HarmonyButtonSize.md => const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
        HarmonyButtonSize.lg => const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
      };

  BoxConstraints? get _constraints => widget.size == HarmonyButtonSize.md
      ? const BoxConstraints(minHeight: 40)
      : null;

  TextStyle? get _textStyle => switch (widget.size) {
        HarmonyButtonSize.sm => AppTypography.textTheme.labelMedium,
        HarmonyButtonSize.md => AppTypography.textTheme.labelLarge,
        HarmonyButtonSize.lg =>
          AppTypography.textTheme.labelLarge?.copyWith(fontSize: 16),
      };

  Color _backgroundColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (widget.variant) {
      HarmonyButtonVariant.primary =>
        _isHovered ? AppColors.accentBlueHover : AppColors.accentBlue,
      HarmonyButtonVariant.secondary => cs.surfaceContainerHighest,
      HarmonyButtonVariant.danger =>
        AppColors.accentRed.withValues(alpha: 0.12),
      HarmonyButtonVariant.ghost => Colors.transparent,
    };
  }

  Color _foregroundColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (widget.variant) {
      HarmonyButtonVariant.primary => Colors.white,
      HarmonyButtonVariant.secondary => cs.onSurface,
      HarmonyButtonVariant.danger => AppColors.accentRed,
      HarmonyButtonVariant.ghost => cs.onSurfaceVariant,
    };
  }

  Border? get _border => switch (widget.variant) {
        HarmonyButtonVariant.secondary =>
          Border.all(color: AppColors.borderDefault),
        HarmonyButtonVariant.ghost =>
          Border.all(color: Colors.transparent),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final effectiveOpacity = _isInteractive ? 1.0 : 0.4;
    final pressedScale = _isPressed ? 0.96 : 1.0;
    final bg = _backgroundColor(context);
    final fg = _foregroundColor(context);

    return Focus(
      focusNode: _focusNode,
      child: MouseRegion(
        onEnter: _isInteractive ? (_) => _onHoverChanged(true) : null,
        onExit: _isInteractive ? (_) => _onHoverChanged(false) : null,
        cursor: _isInteractive
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: ScaleTransition(
          scale: _hoverScale,
          child: AnimatedScale(
            scale: pressedScale,
            duration: const Duration(milliseconds: 80),
            child: Opacity(
              opacity: effectiveOpacity,
              child: GestureDetector(
                onTap: _isInteractive ? widget.onPressed : null,
                onTapDown: _isInteractive
                    ? (_) => setState(() => _isPressed = true)
                    : null,
                onTapUp: _isInteractive
                    ? (_) => setState(() => _isPressed = false)
                    : null,
                onTapCancel: _isInteractive
                    ? () => setState(() => _isPressed = false)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: _padding,
                  constraints: _constraints,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: AppRadius.mdRadius,
                    border: _isFocused
                        ? Border.all(color: AppColors.accentBlue, width: 2)
                        : _border,
                  ),
                  alignment: Alignment.center,
                  child: widget.isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(fg),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: fg, size: 16),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                            Text(
                              widget.label,
                              style: _textStyle?.copyWith(color: fg),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
