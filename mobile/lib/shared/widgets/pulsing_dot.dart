import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Pastille animée avec effet "respiration" — halo qui s'élargit sur 4 secondes.
/// Remplace HarmonyStatusDot dans les contextes où l'animation doit être plus douce.
class PulsingDot extends StatefulWidget {
  const PulsingDot({
    super.key,
    this.color = AppColors.accentGreen,
    this.size = 10.0,
  });

  final Color color;
  final double size;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _scale = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return SizedBox(
      width: s * 2.5,
      height: s * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo pulsant (fond)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: _opacity.value),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Pastille centrale (fixe)
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
