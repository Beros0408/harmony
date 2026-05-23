import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled, this.hasError = false});

  final int filled;
  final bool hasError;

  static const int _total = 4;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_total, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasError
                  ? AppColors.accentRed
                  : isFilled
                      ? AppColors.accentBlue
                      : Colors.transparent,
              border: Border.all(
                color: hasError
                    ? AppColors.accentRed
                    : isFilled
                        ? AppColors.accentBlue
                        : AppColors.borderDefault,
                width: 2,
              ),
            ),
          ),
        );
      }),
    );
  }
}
