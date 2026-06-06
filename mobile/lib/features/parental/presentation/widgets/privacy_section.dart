import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../data/services/privacy_service.dart';

// Résultat retourné par le premier dialog de suppression.
enum _DeleteAction { exportFirst, deleteDefinitive }

/// Section RGPD affichée en bas de l'écran détail enfant (côté parent).
///
/// Deux actions :
/// - Exporter les données (GET /privacy/export/{id} → fichier JSON local)
/// - Supprimer toutes les données (DELETE /privacy/data/{id}, double confirmation)
class PrivacySection extends StatefulWidget {
  const PrivacySection({
    super.key,
    required this.childId,
    required this.childName,
    this.onDeleted,
  });

  final String childId;
  final String childName;

  /// Appelé après une suppression réussie (typiquement : `context.pop()`).
  final VoidCallback? onDeleted;

  @override
  State<PrivacySection> createState() => _PrivacySectionState();
}

class _PrivacySectionState extends State<PrivacySection> {
  final _service = PrivacyService.instance;

  bool _exporting = false;
  bool _deleting  = false;

  // ─── Export ────────────────────────────────────────────────────────────────

  Future<void> _doExport() async {
    if (_exporting) return;
    if (mounted) setState(() => _exporting = true);

    try {
      final data   = await _service.exportData(widget.childId);
      final result = await _service.saveExportFile(widget.childName, data);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export de ${widget.childName} enregistré.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                result.path,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              if (!result.isExternal) ...[
                const SizedBox(height: 2),
                const Text(
                  'Stockage interne — non visible depuis le gestionnaire de fichiers.',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ],
          ),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 7),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'export : $e'),
          backgroundColor: AppColors.accentRed,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ─── Suppression — dialog 1 ───────────────────────────────────────────────

  Future<void> _showDeleteDialog() async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final action = await showDialog<_DeleteAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(
          Icons.shield_outlined,
          size: 32,
          color: AppColors.accentAmber,
        ),
        title: Text(
          'Données de ${widget.childName}',
          textAlign: TextAlign.center,
          style: tt.titleMedium,
        ),
        content: Text(
          'Supprimer toutes les données effacera l\'historique, les paramètres '
          'et l\'appairage de ${widget.childName}. '
          'Cette action est irréversible.\n\n'
          'Pensez à exporter d\'abord si vous souhaitez garder une copie.',
          textAlign: TextAlign.center,
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          // Exporter d'abord — action recommandée
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Exporter d\'abord'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accentBlue,
                side: const BorderSide(color: AppColors.accentBlue),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
              ),
              onPressed: () => Navigator.pop(ctx, _DeleteAction.exportFirst),
            ),
          ),
          const SizedBox(height: 8),
          // Supprimer définitivement — action destructive, discrète
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentRed.withValues(alpha: 0.75),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
              ),
              onPressed: () =>
                  Navigator.pop(ctx, _DeleteAction.deleteDefinitive),
              child: const Text('Supprimer définitivement'),
            ),
          ),
          const SizedBox(height: 4),
          // Annuler
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdRadius),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    switch (action) {
      case _DeleteAction.exportFirst:
        await _doExport();
      case _DeleteAction.deleteDefinitive:
        await _showFinalConfirmDialog();
      case null:
        break; // dialog fermé sans action
    }
  }

  // ─── Suppression — dialog 2 (confirmation finale) ─────────────────────────

  Future<void> _showFinalConfirmDialog() async {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(
          Icons.warning_amber_rounded,
          size: 32,
          color: AppColors.accentRed.withValues(alpha: 0.85),
        ),
        title: const Text(
          'Dernière confirmation',
          textAlign: TextAlign.center,
        ),
        titleTextStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        content: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.6,
            ),
            children: [
              const TextSpan(
                text: 'Vous allez supprimer définitivement toutes les données '
                    'de ',
              ),
              TextSpan(
                text: widget.childName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(
                text: '. L\'appairage sera également supprimé. '
                    'Cette action ne peut pas être annulée.',
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side: BorderSide(
                color: AppColors.accentRed.withValues(alpha: 0.6),
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Je confirme'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    await _doDelete();
  }

  // ─── Suppression — appel API ───────────────────────────────────────────────

  Future<void> _doDelete() async {
    if (mounted) setState(() => _deleting = true);

    try {
      await _service.deleteData(widget.childId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Toutes les données de ${widget.childName} ont été supprimées.',
          ),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 3),
        ),
      );

      // Notifie le parent pour qu'il revienne en arrière (l'enfant n'existe plus).
      widget.onDeleted?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression : $e'),
          backgroundColor: AppColors.accentRed,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section — même style que les autres sections
        Text(
          'CONFIDENTIALITÉ (RGPD)',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        HarmonyCard(
          padding: AppSpacing.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne d'info RGPD
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    size: 18,
                    color: AppColors.accentBlue,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Conformément au RGPD, vous pouvez à tout moment '
                      'exporter ou supprimer les données de ${widget.childName}.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),
              Divider(color: cs.outlineVariant, height: 1),
              const SizedBox(height: AppSpacing.md),

              // ── Bouton export ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: _exporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined, size: 18),
                  label: Text(
                    _exporting
                        ? 'Export en cours…'
                        : 'Exporter les données',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdRadius),
                  ),
                  onPressed: (_exporting || _deleting) ? null : _doExport,
                ),
              ),

              const SizedBox(height: AppSpacing.xs),

              // Description export
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs),
                child: Text(
                  'Télécharge toutes les données de ${widget.childName} '
                  'au format JSON.',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Bouton suppression — discret, rouge atténué ─────────────
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: _deleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.delete_outline,
                          size: 18,
                          color:
                              AppColors.accentRed.withValues(alpha: 0.7),
                        ),
                  label: Text(
                    _deleting
                        ? 'Suppression en cours…'
                        : 'Supprimer toutes les données',
                    style: TextStyle(
                      color: _deleting
                          ? cs.onSurfaceVariant
                          : AppColors.accentRed.withValues(alpha: 0.7),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdRadius),
                  ),
                  onPressed: (_exporting || _deleting)
                      ? null
                      : _showDeleteDialog,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
