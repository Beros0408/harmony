// Transcriptions are MOCKED — real STT integration in Sprint 5
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:harmony/core/constants/app_colors.dart';
import 'package:harmony/core/constants/app_spacing.dart';
import 'package:harmony/features/voicemail/data/mock/voicemail_mocks.dart';
import 'package:harmony/features/voicemail/presentation/widgets/voicemail_item_card.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/widgets/harmony_app_bar.dart';

class VoicemailScreen extends StatefulWidget {
  const VoicemailScreen({super.key, this.showPushOnLoad = true});

  // Set false in tests to avoid pending Timer
  final bool showPushOnLoad;

  @override
  State<VoicemailScreen> createState() => _VoicemailScreenState();
}

class _VoicemailScreenState extends State<VoicemailScreen>
    with TickerProviderStateMixin {
  late List<HarmonyVoicemail> _voicemails;
  bool _showPush = false;

  late AnimationController _staggerController;
  late AnimationController _pushController;
  late AnimationController _bellController;
  late Animation<Offset> _pushSlide;
  late Animation<double> _bellAngle;

  Timer? _showTimer;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _voicemails = kVoicemails();

    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200 + _voicemails.length * 50),
    )..forward();

    _pushController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pushSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pushController, curve: Curves.easeOut));

    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    _bellAngle = Tween<double>(
      begin: -5 * math.pi / 180,
      end: 5 * math.pi / 180,
    ).animate(CurvedAnimation(parent: _bellController, curve: Curves.easeInOut));

    if (widget.showPushOnLoad) {
      _showTimer = Timer(const Duration(seconds: 2), _triggerPush);
    }
  }

  void _triggerPush() {
    if (!mounted) return;
    setState(() => _showPush = true);
    _pushController.forward();
    _dismissTimer = Timer(const Duration(seconds: 5), _dismissPush);
  }

  void _dismissPush() {
    if (!mounted) return;
    _pushController.reverse().then((_) {
      if (mounted) setState(() => _showPush = false);
    });
  }

  void _markRead(String id) {
    setState(() {
      final i = _voicemails.indexWhere((v) => v.id == id);
      if (i != -1) _voicemails[i] = _voicemails[i].copyWith(isRead: true);
    });
  }

  void _delete(String id) {
    setState(() => _voicemails.removeWhere((v) => v.id == id));
  }

  int get _unreadCount => _voicemails.where((v) => !v.isRead).length;

  @override
  void dispose() {
    _showTimer?.cancel();
    _dismissTimer?.cancel();
    _staggerController.dispose();
    _pushController.dispose();
    _bellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: HarmonyAppBar(title: l10n.voicemailScreenTitle),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(l10n, cs)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAnimatedItem(index),
                    childCount: _voicemails.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildBottomInfo(l10n)),
            ],
          ),
          if (_showPush)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _pushSlide,
                child: _PushToast(
                  l10n: l10n,
                  bellAngle: _bellAngle,
                  callerName: _voicemails.first.callerName,
                  onView: _dismissPush,
                  onDismiss: _dismissPush,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _MetricChip(
              label: l10n.voicemailNewCount(_unreadCount),
              color: AppColors.accentBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _MetricChip(
              label: l10n.voicemailTotal(_voicemails.length),
              color: AppColors.accentGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(int index) {
    final start = index * 0.08;
    final end = (start + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    final vm = _voicemails[index];
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: VoicemailItemCard(
        key: ValueKey(vm.id),
        voicemail: vm,
        onMarkRead: () => _markRead(vm.id),
        onDelete: () => _delete(vm.id),
        onCallBack: () {},
      ),
    );
  }

  Widget _buildBottomInfo(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              l10n.voicemailMockNote,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PushToast extends StatelessWidget {
  const _PushToast({
    required this.l10n,
    required this.bellAngle,
    required this.callerName,
    required this.onView,
    required this.onDismiss,
  });

  final AppLocalizations l10n;
  final Animation<double> bellAngle;
  final String callerName;
  final VoidCallback onView;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (d) {
        if (d.primaryVelocity != null && d.primaryVelocity! < 0) onDismiss();
      },
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: bellAngle,
              builder: (context, child) => Transform.rotate(
                angle: bellAngle.value,
                child: child,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppColors.accentBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.voicemailNewMessageToastTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.voicemailNewMessageToastBody(callerName),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onView,
              child: Text(
                l10n.voicemailViewButton,
                style: const TextStyle(
                  color: AppColors.accentBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
