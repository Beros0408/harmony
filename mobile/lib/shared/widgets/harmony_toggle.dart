import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class HarmonyToggle extends StatelessWidget {
  const HarmonyToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: value ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          _ToggleTrack(value: value),
        ],
      ),
    );
  }
}

class _ToggleTrack extends StatelessWidget {
  const _ToggleTrack({required this.value});

  final bool value;

  // Dimensions : 36×20px
  static const double _width = 36;
  static const double _height = 20;
  static const double _thumbSize = 14;
  static const double _thumbPadding = 3;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_height / 2),
        color: value ? AppColors.accentGreen : AppColors.bgElevated,
        border: Border.all(
          color: value ? AppColors.accentGreen : AppColors.borderDefault,
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            left: value ? _width - _thumbSize - _thumbPadding : _thumbPadding,
            child: Container(
              width: _thumbSize,
              height: _thumbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? AppColors.white : AppColors.textMuted,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
