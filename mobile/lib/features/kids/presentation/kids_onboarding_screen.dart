import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../data/services/kids_storage.dart';
import 'kids_admin_screen.dart';

/// Parcours d'onboarding affiché une seule fois à l'enfant après appairage.
/// 3 pages : Bienvenue → Transparence → C'est parti !
/// Sauvegarde [harmony_kids_onboarding_done] puis navigue vers [KidsAdminScreen].
class KidsOnboardingScreen extends StatefulWidget {
  const KidsOnboardingScreen({super.key, required this.childId});

  final String childId;

  @override
  State<KidsOnboardingScreen> createState() => _KidsOnboardingScreenState();
}

class _KidsOnboardingScreenState extends State<KidsOnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    await KidsStorage.instance.saveKidsOnboardingDone();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => KidsAdminScreen(childId: widget.childId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(current: _currentPage, total: _pageCount),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _WelcomePage(onNext: _next),
                  _TransparencyPage(onNext: _next),
                  _ReadyPage(onFinish: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Barre supérieure : logo + progression ───────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            'Harmony Kids',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          ...List.generate(total, (i) {
            final active = i <= current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              width: i == current ? 20 : 8,
              height: 8,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: active ? cs.primary : cs.outlineVariant,
              ),
            );
          }),
        ],
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
    return _PageLayout(
      icon: const _BigEmoji('👋'),
      title: 'Bienvenue sur\nHarmony Kids',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BodyText(
            'Harmony aide ta famille à trouver un bon équilibre '
            'avec les écrans — sans stress, à votre rythme.',
          ),
          const SizedBox(height: AppSpacing.md),
          _BodyText(
            'Cette app s\'installe sur ton téléphone pour '
            'que ton parent puisse garder un œil bienveillant sur '
            'comment tu utilises ton temps.',
          ),
        ],
      ),
      button: _NextButton(label: 'Suivant', onTap: onNext),
    );
  }
}

// ─── Page 2 : Transparence ───────────────────────────────────────────────────

class _TransparencyPage extends StatelessWidget {
  const _TransparencyPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _PageLayout(
      icon: const _BigEmoji('🔍'),
      title: 'Ce que Harmony voit',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('Ce que ton parent peut voir', visible: true),
          const SizedBox(height: AppSpacing.sm),
          const _TransparencyRow(
            icon: Icons.timer_outlined,
            text: 'Le temps passé sur chaque application',
            visible: true,
          ),
          const _TransparencyRow(
            icon: Icons.apps_outlined,
            text: 'Les applications que tu utilises',
            visible: true,
          ),
          const _TransparencyRow(
            icon: Icons.location_on_outlined,
            text: 'Ta position sur une carte privée',
            visible: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel('Ce que ton parent ne voit PAS', visible: false),
          const SizedBox(height: AppSpacing.sm),
          const _TransparencyRow(
            icon: Icons.chat_bubble_outline,
            text: 'Le contenu de tes messages et conversations',
            visible: false,
          ),
          const _TransparencyRow(
            icon: Icons.photo_library_outlined,
            text: 'Tes photos et vidéos',
            visible: false,
          ),
          const _TransparencyRow(
            icon: Icons.search_outlined,
            text: 'Ce que tu recherches en ligne',
            visible: false,
          ),
        ],
      ),
      button: _NextButton(label: 'Suivant', onTap: onNext),
    );
  }
}

// ─── Page 3 : C'est parti ! ──────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({required this.onFinish});
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return _PageLayout(
      icon: const _BigEmoji('🚀'),
      title: 'C\'est parti !',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BodyText(
            'Tu peux utiliser ton téléphone normalement. '
            'Harmony travaille discrètement en arrière-plan.',
          ),
          const SizedBox(height: AppSpacing.md),
          _BodyText(
            'Si tu as des questions sur ce que voit ou ne voit pas '
            'ton parent, tu peux lui en parler directement — '
            'la transparence, c\'est important pour tout le monde.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _HighlightCard(
            icon: Icons.favorite_border_outlined,
            text: 'Harmony est là pour t\'aider, pas pour t\'espionner.',
          ),
        ],
      ),
      button: _NextButton(label: 'J\'ai compris', onTap: onFinish),
    );
  }
}

// ─── Widgets partagés ────────────────────────────────────────────────────────

class _PageLayout extends StatelessWidget {
  const _PageLayout({
    required this.icon,
    required this.title,
    required this.body,
    required this.button,
  });

  final Widget icon;
  final String title;
  final Widget body;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(height: AppSpacing.xxl),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          body,
          const SizedBox(height: AppSpacing.huge),
          SizedBox(width: double.infinity, child: button),
        ],
      ),
    );
  }
}

class _BigEmoji extends StatelessWidget {
  const _BigEmoji(this.emoji);
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 36)),
      ),
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
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.55,
          ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.visible});
  final String text;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 16,
          color: visible ? cs.primary : cs.error,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: visible ? cs.primary : cs.error,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
        ),
      ],
    );
  }
}

class _TransparencyRow extends StatelessWidget {
  const _TransparencyRow({
    required this.icon,
    required this.text,
    required this.visible,
  });

  final IconData icon;
  final String text;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = visible ? cs.primary : cs.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: visible
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                    decoration: visible ? null : TextDecoration.lineThrough,
                    decorationColor: cs.outline,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            visible ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size: 18,
            color: visible ? cs.primary : cs.error,
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.onPrimaryContainer, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}
