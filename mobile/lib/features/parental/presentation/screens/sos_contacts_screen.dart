import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';
import '../../../contacts/data/models/native_contact.dart';
import '../../../contacts/data/repositories/native_contacts_repository.dart';

/// Écran de gestion des contacts d'urgence SOS pour un enfant.
/// Réutilise NativeContactsRepository (pattern ContactPicker Sprint 5).
class SosContactsScreen extends StatefulWidget {
  const SosContactsScreen({super.key, required this.childId});
  final String childId;

  @override
  State<SosContactsScreen> createState() => _SosContactsScreenState();
}

class _SosContactsScreenState extends State<SosContactsScreen> {
  // Contacts d'urgence en mémoire (persistance SQLCipher prévue Sprint 8)
  final List<NativeContact> _sosContacts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Seed data pour la démo
    WidgetsBinding.instance.addPostFrameCallback((_) => _addSeedContacts());
  }

  void _addSeedContacts() {
    if (_sosContacts.isEmpty) {
      setState(() {
        _sosContacts.addAll([
          const NativeContact(id: 'sos1', displayName: 'Maman', phone: '+33 6 00 00 00 01'),
          const NativeContact(id: 'sos2', displayName: 'Papa', phone: '+33 6 00 00 00 02'),
        ]);
      });
    }
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
            onPressed: () => _showContactPicker(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sosContacts.isEmpty
              ? HarmonyEmptyState(
                  icon: Icons.contacts_outlined,
                  title: l10n.sosContactsEmpty,
                  subtitle: 'Ajoutez des contacts à appeler automatiquement en cas de SOS',
                  cta: l10n.sosContactsAdd,
                  onCtaTap: () => _showContactPicker(context),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Explication
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

                    // Liste contacts SOS
                    ..._sosContacts.asMap().entries.map((e) {
                      final i = e.key;
                      final contact = e.value;
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SosContactTile(
                          contact: contact,
                          priority: i + 1,
                          canMoveUp: i > 0,
                          canMoveDown: i < _sosContacts.length - 1,
                          onMoveUp: () => _swap(i, i - 1),
                          onMoveDown: () => _swap(i, i + 1),
                          onRemove: () => _remove(i),
                          onTest: () => _testSos(contact),
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.lg),

                    // Bouton ajouter
                    OutlinedButton.icon(
                      onPressed: () => _showContactPicker(context),
                      icon: const Icon(Icons.person_add_outlined),
                      label: Text(l10n.sosContactsAdd),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
    );
  }

  void _swap(int i, int j) {
    setState(() {
      final tmp = _sosContacts[i];
      _sosContacts[i] = _sosContacts[j];
      _sosContacts[j] = tmp;
    });
  }

  void _remove(int i) {
    setState(() => _sosContacts.removeAt(i));
  }

  void _testSos(NativeContact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Test SOS → ${contact.displayName} (${contact.phone ?? 'pas de numéro'})'),
        backgroundColor: AppColors.accentAmber,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showContactPicker(BuildContext ctx) async {
    setState(() => _loading = true);
    try {
      final contacts =
          await NativeContactsRepository.instance.fetchAll();
      if (!mounted) return;
      setState(() => _loading = false);
      if (contacts.isEmpty) return;

      await showModalBottomSheet<void>(
        context: ctx,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ContactPickerSheet(
          contacts: contacts,
          onSelected: (c) {
            if (!_sosContacts.any((s) => s.id == c.id)) {
              setState(() => _sosContacts.add(c));
            }
          },
        ),
      );
    } catch (e) {
      setState(() => _loading = false);
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
    required this.onTest,
  });
  final NativeContact contact;
  final int priority;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onRemove;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      child: Row(
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
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.accentRed, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Infos contact
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.displayName,
                    style: Theme.of(context).textTheme.labelLarge),
                if (contact.phone != null)
                  Text(contact.phone!,
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),

          // Contrôles
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
          IconButton(
            icon: const Icon(Icons.sos, size: 18, color: AppColors.accentAmber),
            tooltip: 'Tester',
            onPressed: onTest,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.accentRed),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ─── Picker de contact ───────────────────────────────────────────────────────

class _ContactPickerSheet extends StatefulWidget {
  const _ContactPickerSheet({required this.contacts, required this.onSelected});
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
                    backgroundColor: AppColors.accentBlue.withValues(alpha: 0.15),
                    child: Text(
                      c.displayName.isNotEmpty ? c.displayName[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: AppColors.accentBlue, fontWeight: FontWeight.bold),
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
