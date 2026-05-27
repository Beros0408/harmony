import 'package:flutter/material.dart';

/// Badge doré "PRO" à afficher à côté d'une feature premium verrouillée.
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, this.size = 12});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.5,
        vertical: size * 0.2,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAB308), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(size * 0.4),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
          height: 1,
        ),
      ),
    );
  }
}
