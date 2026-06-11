import 'package:flutter/material.dart';

class BreathingCircle extends StatelessWidget {
  const BreathingCircle({
    super.key,
    required this.scale,
    required this.color,
  });

  final double scale;
  final Color color;

  static const double _baseSize = 220.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _baseSize,
      child: Transform.scale(
        scale: scale,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.75),
                color.withValues(alpha: 0.20),
              ],
              stops: const [0.35, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.30 * scale),
                blurRadius: 52,
                spreadRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
