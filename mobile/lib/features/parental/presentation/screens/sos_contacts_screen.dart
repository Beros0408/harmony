import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';
import '../../../contacts/data/models/native_contact.dart';
import '../../../contacts/data/repositories/native_contacts_repository.dart';
import '../../data/models/sos_contact.dart';
import '../../data/services/sos_contacts_api_service.dart';

/// Écran de gestion des contacts d'urgence SOS pour un enfant.
/// Branché sur le backend via SosContactsApiService (Sprint B2).
class SosContactsScreen extends StatefulWidget {
  const SosContactsScreen({super.key, required this.childId});
  final String childId;

  @override
  State<SosContactsScreen> createState() => _SosContactsScreenState();
}

class _SosContactsScreenState extends State<SosContactsScreen> {
  List<SosContact> _contacts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _loading = true);
    try {
      final contacts =
          await SosContactsApiService.instance.getContacts(widget.childId);
      if (!mounted) return;
      setState(() => _contacts = contacts);
    } catch (_) {
      if (!mounted) return;
      _showError('Erreur de chargement des contacts SOS');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addContact(NativeContact c) async {
    if (c.phone == null || c.phone!.trim().isEmpty) {
      _showError('Ce contact n\'a pas de numéro de téléphone');
      return;
    }
    setState(() => _loading = true);
    try {
      await SosContactsApiService.instance.addContact(
        widget.childId,
        c.displayName,
        c.phone!,
        'parent',
      );
      await _loadContacts();
    } catch (_) {
      if (!mounted) return;
      _showError('Erreur lors de l\'ajout du contact');
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(int i) async {
    final contact = _contacts[i];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ce contact ?'),
        content: Text('${contact.name} sera retiré des contacts SOS.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    try {
      await SosContactsApiService.instance.deleteContact(contact.id);
      await _loadContacts();
    } catch (_) {
      if (!mounted) return;
      _showError('Erreur lors de la suppression du contact');
      setState(() => _loading = false);
    }
  }

  Future<void> _swap(int i, int j) async {
    final a = _contacts[i];
    final b = _contacts[j];
    setState(() => _loading = true);
    try {
      await SosContactsApiService.instance.updateOrder(a.id, b.sortOrder);
      await SosContactsApiService.instance.updateOrder(b.id, a.sortOrder);
      await _loadContacts();
    } catch (_) {
      if (!mounted) return;
      _showError('Erreur lors du réordonnement');
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: l10n.sosContactsTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: l10n.sosContactsAdd,
            onPressed: _showContactPicker,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? HarmonyEmptyState(
                  icon: Icons.contacts_outlined,
                  title: l10n.sosContactsEmpty,
                  subtitle:
                      'Ajoutez des contacts à appeler automatiquement en cas de SOS',
                  cta: l10n.sosContactsAdd,
                  onCtaTap: _showContactPicker,
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    HarmonyCard(
                      padding: AppSpacing.md,
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.accentAmber, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Ces contacts seront appelés dans l\'ordre en cas de SOS. '
                              'L\'appel 112 reste toujours la priorité.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    ..._contacts.asMap().entries.map((e) {
                      final i = e.key;
                      final contact = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SosContactTile(
                          contact: contact,
                          priority: i + 1,
                          canMoveUp: i > 0,
                          canMoveDown: i < _contacts.length - 1,
                          onMoveUp: () => _swap(i, i - 1),
                          onMoveDown: () => _swap(i, i + 1),
                          onRemove: () => _confirmDelete(i),
                          onCall: () =>
                              launchUrl(Uri.parse('tel:${contact.phone}')),
                          onSms: () => launchUrl(
                              Uri(scheme: 'sms', path: contact.phone)),
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
                      onPressed: _showContactPicker,
                      icon: const Icon(Icons.person_add_outlined),
                      label: Text(l10n.sosContactsAdd),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
    );
  }

  Future<void> _showContactPicker() async {
    setState(() => _loading = true);
    try {
      // Correction 1 — demande la permission avant tout accès aux contacts
      final granted =
          await NativeContactsRepository.instance.requestPermission();
      if (!mounted) return;
      if (!granted) {
        setState(() => _loading = false);
        _showError('Permission contacts refusée');
        return;
      }

      final contacts = await NativeContactsRepository.instance.fetchAll();
      if (!mounted) return;
      setState(() => _loading = false);

      // Correction 2 — liste vide : Snackbar explicatif au lieu du return silencieux
      if (contacts.isEmpty) {
        _showError('Aucun contact trouvé sur cet appareil');
        return;
      }

      // Correction 4 — this.context + guard mounted pour éviter le context stale
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ContactPickerSheet(
          contacts: contacts,
          onSelected: (c) {
            final alreadyAdded = _contacts.any((s) => s.phone == c.phone);
            if (!alreadyAdded) _addContact(c);
          },
        ),
      );
    } catch (_) {
      // Correction 3 — Snackbar d'erreur visible, jamais de crash silencieux
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Erreur lors de l\'ouverture des contacts');
    }
  }
}

// ─── Tuile contact SOS ────────────────────────────────────────────────────────

class _SosContactTile extends StatelessWidget {
  const _SosContactTile({
    required this.contact,
    required this.priority,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    required this.onCall,
    required this.onSms,
  });
  final SosContact contact;
  final int priority;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;
  final VoidCallback onCall;
  final VoidCallback onSms;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return HarmonyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Ligne 1 : badge · nom/numéro · flèches · supprimer ──
          Row(
            children: [
              // Badge priorité
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$priority',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.accentRed,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Infos contact
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name,
                        style: Theme.of(context).textTheme.labelLarge),
                    Text(contact.phone,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),

              // Réordonnement ↑↓
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                    onPressed: canMoveUp ? onMoveUp : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                    onPressed: canMoveDown ? onMoveDown : null,
                  ),
                ],
              ),

              // Supprimer
              IconButton(
                icon: const Icon(Icons.close,
                    size: 18, color: AppColors.accentRed),
                onPressed: onRemove,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Ligne 2 : boutons larges Appeler · SMS ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone, size: 18),
                  label: Text(l10n.sosContactsCall),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentGreen,
                    side: const BorderSide(color: AppColors.accentGreen),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSms,
                  icon: const Icon(Icons.sms, size: 18),
                  label: Text(l10n.sosContactsSms),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentBlue,
                    side: const BorderSide(color: AppColors.accentBlue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Picker de contact ───────────────────────────────────────────────────────

class _ContactPickerSheet extends StatefulWidget {
  const _ContactPickerSheet(
      {required this.contacts, required this.onSelected});
  final List<NativeContact> contacts;
  final ValueChanged<NativeContact> onSelected;

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  String _query = '';

  List<NativeContact> get _filtered => _query.isEmpty
      ? widget.contacts
      : widget.contacts
          .where((c) =>
              c.displayName.toLowerCase().contains(_query.toLowerCase()) ||
              (c.phone?.contains(_query) ?? false))
          .toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outline,
              borderRadius: AppRadius.smRadius,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SearchBar(
              hintText: 'Rechercher un contact…',
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.accentBlue.withValues(alpha: 0.15),
                    child: Text(
                      c.displayName.isNotEmpty
                          ? c.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(c.displayName),
                  subtitle: c.phone != null ? Text(c.phone!) : null,
                  onTap: () {
                    widget.onSelected(c);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
