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
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // Navigation automatique après 2.5 s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go(RouteNames.auth);
    });
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
          // Voile sombre pour lisibilité du texte
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),
          // Contenu centré avec fade-in
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Harmony',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.splashTagline,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
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
          ),
        ],
      ),
    );
  }
}
