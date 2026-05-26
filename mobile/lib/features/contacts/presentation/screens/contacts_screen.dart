import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';
import '../../../../shared/widgets/harmony_search_bar.dart';
import '../../data/models/native_contact.dart';
import '../../logic/contacts_cubit.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ContactsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: l10n.contactsScreenTitle,
        // Phase 4 — refresh button so the user can force-reload at any time
        actions: [
          BlocBuilder<ContactsCubit, ContactsState>(
            builder: (context, state) => IconButton(
              icon: state is ContactsLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_outlined),
              tooltip: 'Rafraîchir les contacts',
              onPressed: state is ContactsLoading
                  ? null
                  : () => context.read<ContactsCubit>().load(),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) => switch (state) {
          ContactsInitial() || ContactsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          ContactsPermissionDenied() => HarmonyEmptyState(
              icon: Icons.contacts_outlined,
              title: l10n.contactsPermissionTitle,
              subtitle: l10n.contactsPermissionSubtitle,
              cta: l10n.contactsPermissionCta,
              onCtaTap: () =>
                  context.read<ContactsCubit>().requestPermission(),
            ),
          ContactsError(:final message) => HarmonyEmptyState(
              icon: Icons.error_outline,
              title: 'Erreur',
              subtitle: message,
              cta: 'Réessayer',
              onCtaTap: () => context.read<ContactsCubit>().load(),
            ),
          ContactsLoaded(:final contacts, :final query, :final rawCount) =>
            _ContactsListView(
              contacts: contacts,
              initialQuery: query,
              rawCount: rawCount,
            ),
        },
      ),
    );
  }
}

// ─── List + search view ───────────────────────────────────────────────────────

class _ContactsListView extends StatefulWidget {
  const _ContactsListView({
    required this.contacts,
    required this.initialQuery,
    required this.rawCount,
  });

  final List<NativeContact> contacts;
  final String initialQuery;

  /// Raw contact count returned by flutter_contacts (for debug empty state).
  final int rawCount;

  @override
  State<_ContactsListView> createState() => _ContactsListViewState();
}

class _ContactsListViewState extends State<_ContactsListView> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contacts = widget.contacts;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: HarmonySearchBar(
            hintText: 'Rechercher un contact...',
            controller: _ctrl,
            onChanged: (v) => context.read<ContactsCubit>().search(v),
          ),
        ),
        Expanded(
          child: contacts.isEmpty
              ? _EmptyContactsDebug(rawCount: widget.rawCount)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: contacts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) =>
                      _ContactTile(contact: contacts[i]),
                ),
        ),
      ],
    );
  }
}

// ─── Phase 5 — Debug empty state with raw contact count ──────────────────────

class _EmptyContactsDebug extends StatelessWidget {
  const _EmptyContactsDebug({required this.rawCount});
  final int rawCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_outlined,
                color: cs.onSurfaceVariant,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun contact trouvé',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              // Phase 5 — diagnostic card: show raw flutter_contacts count
              '$rawCount contact(s) retourné(s) par flutter_contacts\n'
              'Vérifie que tu as des contacts dans Google Contacts ou\n'
              'dans le carnet d\'adresses de l\'émulateur.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => context.read<ContactsCubit>().load(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Rafraîchir'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Individual contact tile ──────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});
  final NativeContact contact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return HarmonyCard(
      padding: AppSpacing.sm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            _Avatar(initials: contact.initials),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (contact.phone != null)
                    Text(
                      contact.phone!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    )
                  else
                    Text(
                      'Aucun numéro',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.accentBlue,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
