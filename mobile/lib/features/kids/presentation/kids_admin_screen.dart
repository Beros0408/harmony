import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../parental/data/repositories/location_repository.dart';
import '../../parental/data/services/i_location_service.dart';
import '../../parental/data/services/location_service.dart';
import '../data/services/command_polling_service.dart';
import '../data/services/content_filter_service.dart';
import '../data/services/device_admin_service.dart';
import '../data/services/kids_link_verification_service.dart';
import '../data/services/kids_storage.dart';
import '../data/services/screen_time_blocking_service.dart';
import '../data/services/screen_time_upload_service.dart';
import '../data/services/unlink_request_service.dart';
import '../data/services/usage_stats_service.dart';
import 'accessibility_permission_screen.dart';
import 'kids_pairing_screen.dart';
import 'screen_time_permission_screen.dart';

/// États possibles d'une demande de déliage côté enfant.
enum _UnlinkState { none, pending, approved, rejected }

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
  final _adminService  = DeviceAdminService.instance;
  final _filterService = ContentFilterService.instance;

  bool _isAdminActive      = false;
  bool _isFiltering        = false;
  bool _loading            = false;
  bool _screenTimeGranted  = false;
  bool _blockingGranted    = false;
  bool _locationGranted    = false;
  String? _errorMessage;

  StreamSubscription? _locationSub;

  // ── État déliage ──────────────────────────────────────────────────────────
  _UnlinkState _unlinkState = _UnlinkState.none;
  bool _unlinkLoading       = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAdminStatus();
    _refreshScreenTimePermission();
    _refreshBlockingStatus();
    _refreshLocationPermission();

    if (widget.childId != null) {
      // Démarre le polling des commandes + plannings + filtrage + déliage
      CommandPollingService.instance
        ..onUnlinkApproved = _onUnlinkApproved
        ..onUnlinkRejected = _onUnlinkRejected
        ..start(widget.childId!);

      // Restaure l'état de déliage si l'app a été fermée entre la demande et l'approbation
      _initUnlinkStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CommandPollingService.instance.clearUnlinkCallbacks();
    _stopLocationTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAdminStatus();
      _refreshScreenTimePermission();
      _refreshBlockingStatus();
      _refreshLocationPermission();
      _verifyLinkOnResume();
    }
  }

  Future<void> _refreshScreenTimePermission() async {
    final granted = await UsageStatsService.instance.isPermissionGranted();
    if (!mounted) return;
    setState(() => _screenTimeGranted = granted);
    // Lance la remontée si la permission vient d'être accordée
    if (granted && widget.childId != null) {
      ScreenTimeUploadService.instance.start();
    }
  }

  Future<void> _refreshBlockingStatus() async {
    final granted =
        await ScreenTimeBlockingService.instance.isAccessibilityGranted();
    if (mounted) setState(() => _blockingGranted = granted);
  }

  Future<void> _refreshLocationPermission() async {
    final status = await LocationService.instance.checkPermissions();
    final granted = status == LocationPermissionStatus.granted ||
        status == LocationPermissionStatus.grantedBackground;
    if (mounted) setState(() => _locationGranted = granted);
    if (granted) _startLocationTracking();
  }

  void _startLocationTracking() {
    if (_locationSub != null) return; // déjà actif
    LocationService.instance.startTracking();
    _locationSub = LocationService.instance
        .positionStream('current')
        .listen((point) => LocationRepository.instance.addPoint(point));
  }

  void _stopLocationTracking() {
    _locationSub?.cancel();
    _locationSub = null;
    LocationService.instance.stopTracking();
  }

  Future<void> _requestLocationPermission() async {
    final status = await LocationService.instance.requestPermissions();
    final granted = status == LocationPermissionStatus.granted ||
        status == LocationPermissionStatus.grantedBackground;
    if (mounted) setState(() => _locationGranted = granted);
    if (granted) _startLocationTracking();
  }

  // ── Vérification du lien serveur (protection appairage fantôme) ──────────

  /// Vérifie au retour au premier plan que le lien est toujours actif.
  /// Si le serveur répond "non lié", nettoie l'état local et navigue vers
  /// l'écran d'appairage. En cas d'erreur réseau, ne fait rien.
  Future<void> _verifyLinkOnResume() async {
    // Ne pas vérifier si un déliage est déjà en cours via la procédure normale
    if (_unlinkState == _UnlinkState.approved) return;
    final childId = widget.childId;
    if (childId == null) return;

    try {
      final linked =
          await KidsLinkVerificationService.instance.isLinked(childId);
      if (!linked && mounted) {
        await _clearLocalAndReturnToPairing();
      }
    } catch (_) {
      // Réseau injoignable → conserver l'état, réessayer à la prochaine reprise
    }
  }

  /// Nettoie l'état local (admin, polling, stockage) et navigue vers l'appairage.
  /// Appelé quand le serveur confirme que le lien n'existe plus.
  Future<void> _clearLocalAndReturnToPairing() async {
    CommandPollingService.instance.stop();
    CommandPollingService.instance.clearUnlinkCallbacks();
    try {
      await _adminService.removeAdmin();
    } catch (_) {
      // Le retrait admin peut échouer si non actif — non bloquant
    }
    try {
      await KidsStorage.instance.clearChildId();
      // Sprint S16 — réinitialise l'onboarding pour le prochain appairage.
      await KidsStorage.instance.clearKidsOnboardingDone();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const KidsPairingScreen()),
      (_) => false,
    );
  }

  // ── Statut admin + filtre ─────────────────────────────────────────────────

  Future<void> _refreshAdminStatus() async {
    final active    = await _adminService.isAdminActive();
    final filtering = await _filterService.isFiltering();
    if (mounted) {
      setState(() {
        _isAdminActive = active;
        _isFiltering   = filtering;
      });
    }
  }

  Future<void> _onActivatePressed() async {
    setState(() { _loading = true; _errorMessage = null; });
    try {
      await _adminService.requestAdmin();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Impossible d\'ouvrir les paramètres. Réessaie.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onLockPressed() async {
    setState(() { _loading = true; _errorMessage = null; });
    try {
      await _adminService.lockNow();
    } on PlatformException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message ?? 'Verrouillage impossible.');
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Erreur inattendue. Réessaie.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Déliage ───────────────────────────────────────────────────────────────

  /// Vérifie au démarrage si une demande est déjà en cours (reprise après fermeture app).
  Future<void> _initUnlinkStatus() async {
    final childId = widget.childId;
    if (childId == null) return;
    try {
      final result = await UnlinkRequestService.instance.getStatus(childId);
      if (!mounted) return;
      if (result.status == 'pending') {
        setState(() => _unlinkState = _UnlinkState.pending);
      } else if (result.status == 'approved' && result.requestId != null) {
        // Approuvé pendant que l'app était fermée → exécuter immédiatement
        _executeUnlink(result.requestId!);
      } else if (result.status == 'rejected') {
        setState(() => _unlinkState = _UnlinkState.rejected);
      }
    } catch (_) {
      // Réseau indisponible au démarrage — l'état restera 'none' ; le polling prend le relais
    }
  }

  /// Demande confirmation, puis envoie la demande de déliage au backend.
  Future<void> _requestUnlink() async {
    final childId = widget.childId;
    if (childId == null) return;

    // Dialog de confirmation avant d'envoyer
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demander à délier cet appareil ?'),
        content: const Text(
          'Une notification sera envoyée à ton parent.\n'
          'Le déliage ne sera effectif que s\'il l\'approuve.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Envoyer la demande'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() { _unlinkLoading = true; _errorMessage = null; });
    try {
      await UnlinkRequestService.instance.createRequest(childId);
      if (mounted) {
        setState(() => _unlinkState = _UnlinkState.pending);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Impossible d\'envoyer la demande. Réessaie.');
      }
    } finally {
      if (mounted) setState(() => _unlinkLoading = false);
    }
  }

  /// Callback du polling : le parent a approuvé — exécuter le déliage.
  void _onUnlinkApproved(String requestId) {
    if (!mounted) return;
    _executeUnlink(requestId);
  }

  /// Callback du polling : le parent a refusé.
  void _onUnlinkRejected() {
    if (!mounted) return;
    setState(() { _unlinkState = _UnlinkState.rejected; });
  }

  /// Exécute le déliage complet :
  ///   1. Retire les droits admin Android (DevicePolicyManager.removeActiveAdmin)
  ///   2. Efface le child_id local (retour à l'écran appairage)
  ///   3. Confirme la suppression de family_links au backend
  Future<void> _executeUnlink(String requestId) async {
    final childId = widget.childId;
    if (childId == null) return;

    setState(() => _unlinkState = _UnlinkState.approved);

    // Arrête le polling avant d'effacer les données locales
    CommandPollingService.instance.stop();
    CommandPollingService.instance.clearUnlinkCallbacks();

    try {
      // 1. Retire le droit administrateur Android (immédiat, sans confirmation système)
      await _adminService.removeAdmin();
    } catch (e) {
      // Le retrait peut échouer si l'admin n'était pas actif — on continue quand même
      debugPrint('[KidsAdminScreen] removeAdmin non bloquant: $e');
    }

    try {
      // 2. Efface l'appairage local → l'app reviendra à KidsPairingScreen au prochain démarrage
      await KidsStorage.instance.clearChildId();
      // Sprint S16 — réinitialise l'onboarding pour le prochain appairage.
      await KidsStorage.instance.clearKidsOnboardingDone();

      // 3. Supprime family_links côté backend
      await UnlinkRequestService.instance.executeUnlink(requestId, childId);
    } catch (e) {
      debugPrint('[KidsAdminScreen] erreur executeUnlink backend: $e');
      // On navigue quand même : l'état local est propre même si le réseau a coupé
    }

    if (!mounted) return;
    // Navigue vers l'écran d'appairage en vidant la pile de navigation
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const KidsPairingScreen()),
      (_) => false,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
                const SizedBox(height: AppSpacing.md),

                // ── Statut filtrage DNS (transparence légale) ─────────────
                _FilterStatusCard(isFiltering: _isFiltering),
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

                // ── Erreur générale ───────────────────────────────────────
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ErrorCard(message: _errorMessage!),
                ],

                const SizedBox(height: AppSpacing.xxxl),

                // ── Section temps d'écran ─────────────────────────────────
                _ScreenTimeSection(
                  granted: _screenTimeGranted,
                  onTap: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const ScreenTimePermissionScreen(),
                      ),
                    );
                    _refreshScreenTimePermission();
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Section blocage doux ──────────────────────────────────
                _BlockingSection(
                  granted: _blockingGranted,
                  onTap: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const AccessibilityPermissionScreen(),
                      ),
                    );
                    _refreshBlockingStatus();
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Section localisation ──────────────────────────────────
                _LocationSection(
                  granted: _locationGranted,
                  onRequestPermission: _requestLocationPermission,
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // ── Section déliage ───────────────────────────────────────
                _UnlinkSection(
                  unlinkState: _unlinkState,
                  unlinkLoading: _unlinkLoading,
                  onRequestUnlink: widget.childId != null ? _requestUnlink : null,
                  onResetRejected: () => setState(() => _unlinkState = _UnlinkState.none),
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
    );
  }
}

// ─── Section temps d'écran ───────────────────────────────────────────────────

class _ScreenTimeSection extends StatelessWidget {
  const _ScreenTimeSection({required this.granted, required this.onTap});
  final bool granted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color  = granted ? AppColors.accentGreen : AppColors.accentAmber;
    final icon   = granted ? Icons.check_circle_outline : Icons.bar_chart_rounded;
    final status = granted ? 'Suivi actif' : 'À activer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TEMPS D\'ÉCRAN',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesure du temps d\'écran',
                        style: tt.labelLarge?.copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status,
                        style: tt.bodySmall?.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section blocage doux ─────────────────────────────────────────────────────

class _BlockingSection extends StatelessWidget {
  const _BlockingSection({required this.granted, required this.onTap});
  final bool granted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final color  = granted ? AppColors.accentGreen : AppColors.accentAmber;
    final icon   = granted ? Icons.bedtime : Icons.bedtime_outlined;
    final status = granted ? 'Rappels actifs' : 'À activer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LIMITES DE TEMPS D\'ÉCRAN',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rappels doux de pause',
                        style: tt.labelLarge?.copyWith(color: cs.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status,
                        style: tt.bodySmall?.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section localisation ────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.granted,
    required this.onRequestPermission,
  });

  final bool granted;
  final VoidCallback onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final color  = granted ? AppColors.accentGreen : AppColors.accentAmber;
    final icon   = granted ? Icons.location_on : Icons.location_off_outlined;
    final status = granted ? 'Partage actif' : 'À autoriser';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCALISATION',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Position partagée avec le parent',
                      style: tt.labelLarge?.copyWith(color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      granted
                          ? 'Ta position est partagée avec ton parent sur une carte privée.'
                          : status,
                      style: tt.bodySmall?.copyWith(color: color),
                    ),
                  ],
                ),
              ),
              if (!granted)
                TextButton(
                  onPressed: onRequestPermission,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentAmber,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: const Text('Autoriser'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section déliage ─────────────────────────────────────────────────────────

class _UnlinkSection extends StatelessWidget {
  const _UnlinkSection({
    required this.unlinkState,
    required this.unlinkLoading,
    required this.onRequestUnlink,
    required this.onResetRejected,
  });

  final _UnlinkState unlinkState;
  final bool unlinkLoading;
  final VoidCallback? onRequestUnlink;
  final VoidCallback onResetRejected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DÉLIAGE',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        switch (unlinkState) {
          _UnlinkState.none => _buildNoneState(context, cs, tt),
          _UnlinkState.pending => _buildPendingCard(context, cs, tt),
          _UnlinkState.approved => _buildApprovedCard(context, cs, tt),
          _UnlinkState.rejected => _buildRejectedCard(context, cs, tt),
        },
      ],
    );
  }

  Widget _buildNoneState(BuildContext context, ColorScheme cs, TextTheme tt) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.link_off, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Si tu souhaites retirer cet appareil du contrôle parental, '
                  'ton parent doit approuver la demande.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          icon: unlinkLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.link_off),
          label: const Text('Demander à délier cet appareil'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.accentAmber,
            side: const BorderSide(color: AppColors.accentAmber),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: (unlinkLoading || onRequestUnlink == null)
              ? null
              : onRequestUnlink,
        ),
      ],
    );
  }

  Widget _buildPendingCard(BuildContext context, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentAmber,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demande envoyée',
                  style: tt.labelMedium?.copyWith(
                    color: AppColors.accentAmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'En attente de l\'accord de ton parent (vérification toutes les 15 s).',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedCard(BuildContext context, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Approuvé — déliage en cours…',
              style: tt.bodySmall?.copyWith(color: AppColors.accentGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedCard(BuildContext context, ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block, color: AppColors.accentRed, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Demande refusée par le parent.',
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.accentRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onResetRejected,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: cs.onSurfaceVariant,
            ),
            child: const Text('Faire une nouvelle demande'),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets internes (inchangés par rapport au sprint précédent) ─────────────

class _AdminStatusCard extends StatelessWidget {
  const _AdminStatusCard({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color   = isActive ? AppColors.accentGreen : cs.onSurfaceVariant;
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

/// Informe l'enfant que le filtrage DNS est actif — obligation de transparence.
class _FilterStatusCard extends StatelessWidget {
  const _FilterStatusCard({required this.isFiltering});
  final bool isFiltering;

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final color = isFiltering ? AppColors.accentBlue : cs.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtrage de contenu',
                  style: tt.labelMedium?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  isFiltering
                      ? 'Actif — certains sites sont bloqués par ton parent.'
                      : 'Désactivé',
                  style: tt.bodySmall?.copyWith(color: color),
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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
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
              message,
              style: tt.bodySmall?.copyWith(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );
  }
}
