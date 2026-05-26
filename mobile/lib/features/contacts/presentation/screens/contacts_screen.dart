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
      appBar: HarmonyAppBar(title: l10n.contactsScreenTitle),
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
          ContactsLoaded(:final contacts, :final query) => _ContactsListView(
              contacts: contacts,
              initialQuery: query,
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
  });

  final List<NativeContact> contacts;
  final String initialQuery;

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
    final l10n = AppLocalizations.of(context)!;
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
              ? HarmonyEmptyState(
                  icon: Icons.person_search_outlined,
                  title: l10n.contactsEmpty,
                )
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
