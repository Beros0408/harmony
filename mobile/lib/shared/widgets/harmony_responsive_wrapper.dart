import 'package:flutter/material.dart';

/// Centers content on wide screens with a 480px max-width (mobile-first).
/// On mobile, passes through without any wrapping.
class HarmonyResponsiveWrapper extends StatelessWidget {
  const HarmonyResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 480,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth <= maxWidth) {
      return child;
    }

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
