import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../logic/pairing_cubit.dart';

class AddChildPairingScreen extends StatefulWidget {
  const AddChildPairingScreen({super.key});

  @override
  State<AddChildPairingScreen> createState() => _AddChildPairingScreenState();
}

class _AddChildPairingScreenState extends State<AddChildPairingScreen> {
  final _nameController = TextEditingController();
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;
  bool _nameIsValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(
      () => setState(
        () => _nameIsValid = _nameController.text.trim().isNotEmpty,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(DateTime expiresAt) {
    _countdownTimer?.cancel();
    final initial = expiresAt.difference(DateTime.now());
    _remaining = initial.isNegative ? Duration.zero : initial;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final diff = expiresAt.difference(DateTime.now());
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
      if (diff.inSeconds <= 0) _countdownTimer?.cancel();
    });
  }

  String _formatCountdown(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _countdownColor() {
    if (_remaining.inSeconds <= 30) return AppColors.accentRed;
    if (_remaining.inSeconds <= 120) return AppColors.accentAmber;
    return AppColors.accentGreen;
  }

  // "123456" → "123 · 456"
  String _formatCode(String code) {
    if (code.length == 6) {
      return '${code.substring(0, 3)} · ${code.substring(3)}';
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PairingCubit(),
      child: BlocConsumer<PairingCubit, PairingState>(
        listener: (context, state) {
          if (state is PairingSuccess) _startCountdown(state.expiresAt);
        },
        builder: (context, state) => Scaffold(
          appBar: const HarmonyAppBar(title: 'Ajouter un enfant'),
          body: _buildBody(context, state),
        ),
      ),
    );
  }

  // ─── Routage des états ───────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, PairingState state) {
    if (state is PairingLoading) return _buildLoading(context);
    if (state is PairingSuccess) return _buildSuccess(context, state);
    return _buildForm(context, state);
  }

  // ─── État chargement ─────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Génération du code…',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // ─── État formulaire (initial + erreur) ──────────────────────────────────

  Widget _buildForm(BuildContext context, PairingState state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<PairingCubit>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Icon(Icons.person_add_outlined, size: 56, color: AppColors.accentBlue),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Ajouter un enfant',
          style: tt.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          "Génère un code à partager avec l'app Harmony Kids",
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: "Prénom de l'enfant",
            hintText: 'Ex : Emma',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.child_care_outlined),
          ),
          onSubmitted: (_) {
            if (_nameIsValid) cubit.generate(_nameController.text);
          },
        ),
        if (state is PairingError) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentRed.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.accentRed,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    state.message,
                    style: tt.bodySmall?.copyWith(color: AppColors.accentRed),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        HarmonyButton(
          label: 'Générer un code',
          icon: Icons.lock_outline,
          isDisabled: !_nameIsValid,
          onPressed: _nameIsValid
              ? () => cubit.generate(_nameController.text)
              : null,
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  // ─── État succès ─────────────────────────────────────────────────────────

  Widget _buildSuccess(BuildContext context, PairingSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<PairingCubit>();
    final expired = _remaining == Duration.zero;
    final countdownColor = _countdownColor();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        // Icône succès centrée
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.accentGreen,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Code généré pour ${state.childName}',
          style: tt.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Boîte du code
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accentBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Code cliquable (copie dans le presse-papier)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: state.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copié dans le presse-papier'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatCode(state.code),
                      style: const TextStyle(
                        fontFamily: 'GeistMono',
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.copy_outlined,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Compte à rebours
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    expired
                        ? Icons.timer_off_outlined
                        : Icons.timer_outlined,
                    size: 16,
                    color: countdownColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    expired
                        ? 'Code expiré — régénère un nouveau code'
                        : 'Expire dans ${_formatCountdown(_remaining)}',
                    style: tt.labelMedium?.copyWith(color: countdownColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Texte d'aide
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.accentBlue,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  "Saisis ce code dans l'app Harmony Kids installée sur le téléphone de ton enfant.",
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Bouton régénérer
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Régénérer un code'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentBlue,
            side: const BorderSide(color: AppColors.accentBlue),
            minimumSize: const Size.fromHeight(44),
          ),
          onPressed: () => cubit.generate(state.childName),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Fermer'),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}
