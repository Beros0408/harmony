import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum HarmonyStatus { online, warning, error, offline }

class HarmonyStatusDot extends StatefulWidget {
  const HarmonyStatusDot({
    super.key,
    required this.status,
    this.pulse = false,
    this.size = 10,
  });

  final HarmonyStatus status;
  final bool pulse;
  final double size;

  @override
  State<HarmonyStatusDot> createState() => _HarmonyStatusDotState();
}

class _HarmonyStatusDotState extends State<HarmonyStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Outer ring: full 0→1 cycle
  late Animation<double> _outerScale;
  late Animation<double> _outerOpacity;
  // Inner ring: phase-shifted via Interval(0.35, 1.0)
  late Animation<double> _innerScale;
  late Animation<double> _innerOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _outerScale = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _outerOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _innerScale = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );
    _innerOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.pulse && widget.status == HarmonyStatus.online) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(HarmonyStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && widget.status == HarmonyStatus.online) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _dotColor => switch (widget.status) {
        HarmonyStatus.online => AppColors.accentGreen,
        HarmonyStatus.warning => AppColors.accentAmber,
        HarmonyStatus.error => AppColors.accentRed,
        HarmonyStatus.offline => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final color = _dotColor;

    if (!widget.pulse || widget.status != HarmonyStatus.online) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: widget.status != HarmonyStatus.offline
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      );
    }

    return SizedBox(
      width: widget.size * 2.8,
      height: widget.size * 2.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring (starts immediately)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.scale(
                scale: _outerScale.value,
                child: Opacity(
                  opacity: _outerOpacity.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          // Inner ring (phase-shifted — starts at 35% of cycle)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.scale(
                scale: _innerScale.value,
                child: Opacity(
                  opacity: _innerOpacity.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          // Core dot with glow
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
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
