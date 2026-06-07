import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/router/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Texte fade-in : 0 → 900 ms
  late final Animation<double> _textFade;

  // Bouton CTA fade-in : 990 → 1800 ms (apparaît après le texte)
  late final Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.50, curve: Curves.easeIn),
    );

    _btnFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image signature plein écran
          Image.asset(
            'assets/images/montagne avec brume rose, signature.png',
            fit: BoxFit.cover,
          ),
          // Voile dégradé pour lisibilité du texte blanc
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000), // 20% opacité en haut
                  Color(0xCC000000), // 80% opacité en bas
                ],
              ),
            ),
          ),
          // Mise en page : titre centré + bouton CTA ancré en bas
          Column(
            children: [
              const Spacer(flex: 3),
              // ── Titre + tagline ───────────────────────────────────────────
              FadeTransition(
                opacity: _textFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'KimiaCare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.splashTagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // ── Bouton CTA glassmorphism ──────────────────────────────────
              FadeTransition(
                opacity: _btnFade,
                child: _GlassCtaButton(
                  label: '${l10n.splashCtaButton} →',
                  onTap: () => context.go(RouteNames.dashboard),
                ),
              ),
              const SizedBox(height: 64),
            ],
          ),
        ],
      ),
    );
  }
}

// Bouton "verre dépoli" (glassmorphism) pour le CTA de la landing page
class _GlassCtaButton extends StatelessWidget {
  const _GlassCtaButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.80),
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
