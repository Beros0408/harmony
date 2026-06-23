import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
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

    final l10n = AppLocalizations.of(context)!;

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
                l10n.privacyExportSuccessTitle(widget.childName),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                result.path,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              if (!result.isExternal) ...[
                const SizedBox(height: 2),
                Text(
                  l10n.privacyExportInternalStorageNote,
                  style: const TextStyle(fontSize: 11),
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
          content: Text(l10n.privacyExportError(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;

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
          l10n.privacyDeleteDialogTitle(widget.childName),
          textAlign: TextAlign.center,
          style: tt.titleMedium,
        ),
        content: Text(
          l10n.privacyDeleteDialogBody(widget.childName),
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
              label: Text(l10n.privacyDeleteExportFirst),
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
              child: Text(l10n.privacyDeleteConfirmDestructive),
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
              child: Text(l10n.privacyDialogCancel),
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
    final l10n = AppLocalizations.of(context)!;

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
        title: Text(
          l10n.privacyDeleteFinalTitle,
          textAlign: TextAlign.center,
        ),
        titleTextStyle: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        content: Text(
          l10n.privacyDeleteFinalBody(widget.childName),
          textAlign: TextAlign.center,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.privacyDialogCancel),
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
            child: Text(l10n.privacyDeleteFinalConfirm),
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

    final l10n = AppLocalizations.of(context)!;

    try {
      await _service.deleteData(widget.childId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.privacyDeleteSuccess(widget.childName)),
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
          content: Text(l10n.privacyDeleteError(e.toString())),
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section — même style que les autres sections
        Text(
          l10n.privacySectionTitle,
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
                      l10n.privacyIntro(widget.childName),
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
                        ? l10n.privacyExportLoading
                        : l10n.privacyExportButton,
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
                  l10n.privacyExportDescription(widget.childName),
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
                        ? l10n.privacyDeleteLoading
                        : l10n.privacyDeleteButton,
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
