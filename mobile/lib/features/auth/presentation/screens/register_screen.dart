import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../logic/credentials_auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CredentialsAuthCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<CredentialsAuthCubit, CredentialsAuthState>(
            listener: (context, state) {
              // Navigation gérée par GoRouter (refreshListenable UserSession).
            },
            builder: (context, state) {
              final isLoading = state is CredentialsAuthLoading;
              return _buildBody(context, state, isLoading);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CredentialsAuthState state,
    bool isLoading,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        // ── En-tête ──────────────────────────────────────────────────────────
        const Icon(Icons.person_add_outlined, size: 56, color: AppColors.accentBlue),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Créer un compte parent',
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Surveillez et protégez vos enfants avec Harmony',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Bannière d'erreur ─────────────────────────────────────────────────
        if (state is CredentialsAuthError) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.accentRed, size: 18),
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
          const SizedBox(height: AppSpacing.lg),
        ],

        // ── Prénom ───────────────────────────────────────────────────────────
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Prénom',
            hintText: 'Ex : Marie',
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Email ─────────────────────────────────────────────────────────────
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'parent@exemple.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Mot de passe ──────────────────────────────────────────────────────
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          onSubmitted: (_) => _submit(context),
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Exigences du backend : min 8 car., 1 majuscule, 1 chiffre
        Text(
          '8 caractères minimum · 1 majuscule · 1 chiffre',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Bouton inscription ───────────────────────────────────────────────
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : HarmonyButton(
                label: "S'inscrire",
                icon: Icons.person_add_outlined,
                onPressed: () => _submit(context),
              ),
        const SizedBox(height: AppSpacing.xl),

        // ── Lien connexion ───────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Déjà un compte ?', style: tt.bodyMedium),
            TextButton(
              onPressed: isLoading ? null : () => context.go(RouteNames.login),
              child: const Text('Se connecter'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  void _submit(BuildContext context) {
    context.read<CredentialsAuthCubit>().register(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text,
        );
  }
}
