import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class HarmonyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HarmonyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showGradient = false,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final List<Widget>? actions;
  // Explicit override — set to suppress the auto back button on root screens.
  final Widget? leading;
  final bool showGradient;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null &&
        automaticallyImplyLeading &&
        context.canPop()) {
      final label = AppLocalizations.of(context)?.navBack ?? 'Retour';
      effectiveLeading = _BackButton(tooltip: label);
    }

    final cs = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: showGradient ? null : Colors.transparent,
      flexibleSpace: showGradient
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x1A3B82F6), Colors.transparent],
                ),
              ),
            )
          : null,
      automaticallyImplyLeading: false,
      leading: effectiveLeading,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
        ),
      ),
      actions: [
        if (actions != null) ...actions!,
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: cs.outline),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  const _BackButton({required this.tooltip});
  final String tooltip;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Tooltip(
          message: widget.tooltip,
          child: Center(
            child: AnimatedScale(
              scale: _hovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
