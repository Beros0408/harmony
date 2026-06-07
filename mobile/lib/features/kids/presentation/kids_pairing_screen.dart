import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../data/services/kids_storage.dart';
import '../logic/kids_pairing_cubit.dart';
import 'kids_onboarding_screen.dart';

class KidsPairingScreen extends StatefulWidget {
  const KidsPairingScreen({super.key});

  @override
  State<KidsPairingScreen> createState() => _KidsPairingScreenState();
}

class _KidsPairingScreenState extends State<KidsPairingScreen> {
  final _codeController = TextEditingController();
  bool _codeIsValid = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      setState(
        () => _codeIsValid = _codeController.text.trim().length == 6 &&
            RegExp(r'^\d{6}$').hasMatch(_codeController.text.trim()),
      );
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KidsPairingCubit(),
      child: BlocConsumer<KidsPairingCubit, KidsPairingState>(
        // Sauvegarde child_id en stockage sécurisé dès que l'appairage réussit
        listener: (context, state) {
          if (state is KidsPairingSuccess) {
            KidsStorage.instance.saveChildId(state.childId);
          }
        },
        builder: (context, state) => Scaffold(
          body: SafeArea(child: _buildBody(context, state)),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, KidsPairingState state) {
    if (state is KidsPairingLoading) return _buildLoading(context);
    if (state is KidsPairingSuccess) return _buildSuccess(context, state);
    return _buildForm(context, state);
  }

  // ─── Chargement ──────────────────────────────────────────────────────────

  Widget _buildLoading(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text('Connexion en cours…', style: tt.bodyMedium),
        ],
      ),
    );
  }

  // ─── Formulaire (initial + erreur) ───────────────────────────────────────

  Widget _buildForm(BuildContext context, KidsPairingState state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<KidsPairingCubit>();

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // Icône principale
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_friendly_outlined,
              size: 40,
              color: AppColors.accentBlue,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Text(
          'Harmony Kids',
          style: tt.headlineMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Saisis le code à 6 chiffres affiché sur le téléphone de ton parent.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxxl),

        // Champ de saisie du code
        TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: tt.headlineMedium?.copyWith(
            letterSpacing: 8,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            labelText: 'Code à 6 chiffres',
            hintText: '123456',
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            prefixIcon: const Icon(Icons.vpn_key_outlined),
          ),
          onSubmitted: (_) {
            if (_codeIsValid) cubit.redeem(_codeController.text);
          },
        ),

        // Message d'erreur
        if (state is KidsPairingError) ...[
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

        // Bouton principal
        FilledButton.icon(
          icon: const Icon(Icons.link),
          label: const Text('Lier mon téléphone'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _codeIsValid
              ? () => cubit.redeem(_codeController.text)
              : null,
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  // ─── Succès ──────────────────────────────────────────────────────────────

  Widget _buildSuccess(BuildContext context, KidsPairingSuccess state) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coche verte animée
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.accentGreen,
                size: 52,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Téléphone lié !',
              style: tt.headlineSmall?.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                children: [
                  const TextSpan(text: 'Tu es maintenant lié à\n'),
                  TextSpan(
                    text: state.parentName,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            Text(
              'Profil enfant : ${state.childName}',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Carte info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Ton parent peut maintenant voir ta localisation et gérer les paramètres de ton téléphone depuis l\'app Harmony.',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Sprint S16 — passe d'abord par l'onboarding enfant (une seule fois).
            // KidsOnboardingScreen se termine en pushReplacement vers KidsAdminScreen.
            FilledButton.icon(
              icon: const Icon(Icons.shield_outlined),
              label: const Text('Configurer la protection'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      KidsOnboardingScreen(childId: state.childId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
