import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/services/harmony_services.dart';
import '../../../../core/session/user_session.dart';
import '../../data/services/consent_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _consentChecked = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    if (_isLoading || !_consentChecked) return;
    setState(() => _isLoading = true);
    try {
      final parentId = UserSession.instance.parentId!;
      await ConsentService.instance.recordConsent(
        parentId: parentId,
        consentType: 'data_collection',
        granted: true,
        policyVersion: '1.0',
      );
      await HarmonyServices.tokenStorage.saveOnboardingDone();
      UserSession.instance.completeOnboarding();
      // Navigation explicite : GoRouter ne redirige pas de lui-même depuis
      // /onboarding car aucune clause du redirect ne couvre cette route après
      // que onboardingDone passe à true (return null = statu quo).
      if (mounted) context.go(RouteNames.dashboard);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur réseau. Veuillez réessayer.'),
            backgroundColor: AppColors.accentRed,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(current: _currentPage, total: 3),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _PermissionsPage(onNext: _nextPage),
                  _ConsentPage(
                    checked: _consentChecked,
                    isLoading: _isLoading,
                    onChecked: (v) => setState(() => _consentChecked = v ?? false),
                    onFinish: _finishOnboarding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Barre de progression ────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: active ? AppColors.accentBlue : AppColors.borderDefault,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Page 1 : Bienvenue ──────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageLayout(
      icon: _GlowIcon(
        icon: Icons.spa_outlined,
        color: AppColors.accentGreen,
      ),
      title: 'Bienvenue sur KimiaCare',
      body: Column(
        children: [
          _BodyText(
            'KimiaCare accompagne votre famille vers un usage numérique '
            'serein — à votre rythme, avec bienveillance.',
          ),
          const SizedBox(height: 12),
          _BodyText(
            'Quelques étapes simples pour configurer la protection '
            'de vos enfants, sans jargon technique.',
          ),
        ],
      ),
      cta: _PrimaryButton(label: 'Continuer', onTap: onNext),
    );
  }
}

// ─── Page 2 : Permissions ───────────────────────────────────────────────────

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageLayout(
      icon: _GlowIcon(
        icon: Icons.shield_outlined,
        color: AppColors.accentBlue,
      ),
      title: 'Ce que KimiaCare surveille\npour vous',
      body: Column(
        children: const [
          _FeatureRow(
            icon: Icons.timer_outlined,
            color: AppColors.accentAmber,
            title: 'Temps d\'écran',
            description:
                'Connaissez le temps passé sur chaque application, '
                'sans lire le contenu des messages ou des photos.',
          ),
          SizedBox(height: 14),
          _FeatureRow(
            icon: Icons.block_outlined,
            color: AppColors.accentRed,
            title: 'Filtrage de contenu',
            description:
                'KimiaCare bloque les sites inappropriés au niveau réseau, '
                'directement sur l\'appareil de votre enfant.',
          ),
          SizedBox(height: 14),
          _FeatureRow(
            icon: Icons.location_on_outlined,
            color: AppColors.accentGreen,
            title: 'Localisation',
            description:
                'Retrouvez votre enfant sur une carte privée et '
                'recevez une alerte s\'il quitte une zone de sécurité.',
          ),
        ],
      ),
      cta: _PrimaryButton(label: 'Continuer', onTap: onNext),
    );
  }
}

// ─── Page 3 : Consentement RGPD ──────────────────────────────────────────────

class _ConsentPage extends StatelessWidget {
  const _ConsentPage({
    required this.checked,
    required this.isLoading,
    required this.onChecked,
    required this.onFinish,
  });

  final bool checked;
  final bool isLoading;
  final ValueChanged<bool?> onChecked;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return _OnboardingPageLayout(
      icon: _GlowIcon(
        icon: Icons.privacy_tip_outlined,
        color: AppColors.accentPurple,
      ),
      title: 'Vos données,\nvos droits',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BodyText(
            'KimiaCare collecte uniquement les données nécessaires '
            'au contrôle parental : activité applicative, position GPS '
            'et événements de filtrage réseau.',
          ),
          const SizedBox(height: 20),
          _PolicyPoint(
            icon: Icons.flag_outlined,
            label: 'Finalité',
            value: 'Sécurité numérique de votre enfant',
          ),
          const SizedBox(height: 10),
          _PolicyPoint(
            icon: Icons.calendar_today_outlined,
            label: 'Conservation',
            value: '90 jours maximum, puis suppression automatique',
          ),
          const SizedBox(height: 10),
          _PolicyPoint(
            icon: Icons.manage_accounts_outlined,
            label: 'Vos droits',
            value: 'Accès, rectification et suppression depuis\n'
                'Réglages › Confidentialité',
          ),
          const SizedBox(height: 24),
          _ConsentCheckbox(checked: checked, onChanged: onChecked),
        ],
      ),
      cta: _PrimaryButton(
        label: isLoading ? 'Enregistrement…' : 'Commencer',
        onTap: checked && !isLoading ? onFinish : null,
        isLoading: isLoading,
      ),
    );
  }
}

// ─── Widgets partagés ────────────────────────────────────────────────────────

class _OnboardingPageLayout extends StatelessWidget {
  const _OnboardingPageLayout({
    required this.icon,
    required this.title,
    required this.body,
    required this.cta,
  });

  final Widget icon;
  final String title;
  final Widget body;
  final Widget cta;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: icon),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 20),
          body,
          const SizedBox(height: 40),
          SizedBox(width: double.infinity, child: cta),
        ],
      ),
    );
  }
}

class _GlowIcon extends StatelessWidget {
  const _GlowIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: 44, color: color),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyPoint extends StatelessWidget {
  const _PolicyPoint({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accentPurple),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label : ',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({required this.checked, required this.onChanged});
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: checked
              ? AppColors.accentPurple.withValues(alpha: 0.08)
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: checked ? AppColors.accentPurple : AppColors.borderDefault,
            width: checked ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: checked,
                onChanged: onChanged,
                activeColor: AppColors.accentPurple,
                checkColor: AppColors.white,
                side: const BorderSide(color: AppColors.borderDefault),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'J\'ai lu et j\'accepte la politique de confidentialité de KimiaCare.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: disabled ? 0.4 : 1.0,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          disabledBackgroundColor: AppColors.accentBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}
