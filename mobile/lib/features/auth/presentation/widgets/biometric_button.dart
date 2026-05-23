import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BiometricButton extends StatelessWidget {
  const BiometricButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.bgElevated,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.fingerprint,
          color: AppColors.accentBlue,
          size: 28,
        ),
      ),
    );
  }
}
