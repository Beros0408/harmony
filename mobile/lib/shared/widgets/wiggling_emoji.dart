import 'package:flutter/material.dart';

/// Emoji animé d'un salut unique au lancement (one-shot, pas de boucle).
/// Utiliser pour le 👋 de bienvenue — s'anime une fois après [delay] puis reste immobile.
class WigglingEmoji extends StatefulWidget {
  const WigglingEmoji({
    super.key,
    required this.emoji,
    this.fontSize = 28.0,
  });

  final String emoji;
  final double fontSize;

  @override
  State<WigglingEmoji> createState() => _WigglingEmojiState();
}

class _WigglingEmojiState extends State<WigglingEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Séquence : -15° → +15° → -10° → +5° → 0° (mouvement de salut naturel)
    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.26), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.26, end: 0.26), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.26, end: -0.17), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.17, end: 0.09), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.09, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    // Lancer après le premier frame (évite les pending timers en test)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotation,
      builder: (_, child) => Transform.rotate(
        angle: _rotation.value,
        alignment: const Alignment(0.0, 0.5),
        child: child,
      ),
      child: Text(
        widget.emoji,
        style: TextStyle(fontSize: widget.fontSize),
      ),
    );
  }
}
