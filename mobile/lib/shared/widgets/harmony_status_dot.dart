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
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.75, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.pulse && widget.status == HarmonyStatus.online) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(HarmonyStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && widget.status == HarmonyStatus.online) {
      _controller.repeat();
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
        ),
      );
    }

    return SizedBox(
      width: widget.size * 2.2,
      height: widget.size * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halo pulsant
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
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
          // Dot central
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
