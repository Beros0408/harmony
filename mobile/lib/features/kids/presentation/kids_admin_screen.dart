import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../data/services/command_polling_service.dart';
import '../data/services/device_admin_service.dart';

/// Écran de configuration du mode protection (administrateur d'appareil).
/// Accessible après l'appairage réussi depuis [KidsPairingScreen].
/// Démarre automatiquement le polling des commandes distantes si [childId] est fourni.
class KidsAdminScreen extends StatefulWidget {
  const KidsAdminScreen({super.key, this.childId});

  /// UUID du profil enfant dans Supabase.
  /// Null uniquement si l'écran est ouvert sans appairage préalable (cold start).
  final String? childId;

  @override
  State<KidsAdminScreen> createState() => _KidsAdminScreenState();
}

class _KidsAdminScreenState extends State<KidsAdminScreen>
    with WidgetsBindingObserver {
  final _adminService = DeviceAdminService.instance;

  bool _isAdminActive = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAdminStatus();
    // Démarre le polling si le child_id est connu
    if (widget.childId != null) {
      CommandPollingService.instance.start(widget.childId!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Le polling continue en arrière-plan tant que l'app est vivante ;
    // on ne l'arrête PAS ici pour qu'il persiste même si l'écran est dépilé.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAdminStatus();
    }
  }

  Future<void> _refreshAdminStatus() async {
    final active = await _adminService.isAdminActive();
    if (mounted) setState(() => _isAdminActive = active);
  }

  Future<void> _onActivatePressed() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await _adminService.requestAdmin();
      // Le statut sera mis à jour via didChangeAppLifecycleState au retour.
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Impossible d\'ouvrir les paramètres. Réessaie.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onLockPressed() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await _adminService.lockNow();
      // L'écran se verrouille immédiatement — pas de retour UI attendu.
    } on PlatformException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message ?? 'Verrouillage impossible.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erreur inattendue. Réessaie.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode protection'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Statut admin ──────────────────────────────────────────
                _AdminStatusCard(isActive: _isAdminActive),
                const SizedBox(height: AppSpacing.xl),

                // ── Explication transparente (obligation légale) ──────────
                const _InfoCard(
                  icon: Icons.info_outline,
                  color: AppColors.accentBlue,
                  text:
                      'Pour pouvoir verrouiller cet écran à la demande de ton parent, '
                      'Harmony Kids a besoin des droits "Administrateur d\'appareil" d\'Android. '
                      'Ces droits sont uniquement utilisés pour le verrouillage d\'écran. '
                      'Ton parent et toi pouvez les retirer à tout moment dans les paramètres Android.',
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Bouton activation ─────────────────────────────────────
                if (!_isAdminActive) ...[
                  FilledButton.icon(
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Activer la protection'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _onActivatePressed,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Android affichera un écran de confirmation.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  // Confirmation visuelle quand actif
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.accentGreen,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Protection activée — le parent peut verrouiller cet écran.',
                            style: tt.bodySmall?.copyWith(
                              color: AppColors.accentGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // ── Bouton test verrouillage ──────────────────────────────
                OutlinedButton.icon(
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Verrouiller maintenant (test)'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: _isAdminActive
                        ? AppColors.accentBlue
                        : cs.onSurfaceVariant,
                    side: BorderSide(
                      color: _isAdminActive
                          ? AppColors.accentBlue
                          : cs.outlineVariant,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isAdminActive ? _onLockPressed : null,
                ),
                if (!_isAdminActive) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Active la protection d\'abord.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],

                // ── Erreur ───────────────────────────────────────────────
                if (_errorMessage != null) ...[
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
                            _errorMessage!,
                            style: tt.bodySmall?.copyWith(
                              color: AppColors.accentRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
    );
  }
}

// ─── Widgets internes ────────────────────────────────────────────────────────

class _AdminStatusCard extends StatelessWidget {
  const _AdminStatusCard({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = isActive ? AppColors.accentGreen : cs.onSurfaceVariant;
    final bgColor = isActive
        ? AppColors.accentGreen.withValues(alpha: 0.08)
        : cs.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.accentGreen.withValues(alpha: 0.3)
              : cs.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.shield : Icons.shield_outlined,
            color: color,
            size: 36,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode protection',
                  style: tt.labelLarge?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive ? 'Activé' : 'Non activé',
                  style: tt.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
