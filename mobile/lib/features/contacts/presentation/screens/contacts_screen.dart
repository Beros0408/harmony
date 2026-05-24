import 'package:flutter/material.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_search_bar.dart';
import '../../data/mock/contacts_mocks.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String _query = '';

  List<HarmonyContact> _filtered(ContactGroup group) {
    final list = kContacts.where((c) => c.group == group).toList();
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list.where(
      (c) => c.name.toLowerCase().contains(q) || c.phone.contains(q),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final whitelist = _filtered(ContactGroup.whitelist);
    final blacklist = _filtered(ContactGroup.blacklist);

    return Scaffold(
      appBar: HarmonyAppBar(title: l10n.contactsScreenTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          HarmonySearchBar(
            hintText: 'Rechercher un contact...',
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: AppSpacing.xl),

          _ContactSection(
            title: l10n.contactsSectionWhitelist,
            contacts: whitelist,
            badge: l10n.contactsWhitelistBadge,
            badgeVariant: HarmonyBadgeVariant.success,
            emptyLabel: l10n.contactsEmpty,
            removeLabel: l10n.contactsRemove,
          ),
          const SizedBox(height: AppSpacing.xl),

          _ContactSection(
            title: l10n.contactsSectionBlacklist,
            contacts: blacklist,
            badge: l10n.contactsBlacklistBadge,
            badgeVariant: HarmonyBadgeVariant.danger,
            emptyLabel: l10n.contactsEmpty,
            removeLabel: l10n.contactsRemove,
          ),
          const SizedBox(height: AppSpacing.xxl),

          HarmonyButton(
            label: l10n.contactsAddContact,
            onPressed: () {},
            icon: Icons.add,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.title,
    required this.contacts,
    required this.badge,
    required this.badgeVariant,
    required this.emptyLabel,
    required this.removeLabel,
  });

  final String title;
  final List<HarmonyContact> contacts;
  final String badge;
  final HarmonyBadgeVariant badgeVariant;
  final String emptyLabel;
  final String removeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.md),
        if (contacts.isEmpty)
          HarmonyCard(
            child: Center(
              child: Text(emptyLabel, style: AppTypography.textTheme.bodySmall),
            ),
          )
        else
          HarmonyCard(
            padding: AppSpacing.sm,
            child: Column(
              children: contacts
                  .map(
                    (c) => _ContactTile(
                      contact: c,
                      badge: badge,
                      badgeVariant: badgeVariant,
                      removeLabel: removeLabel,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.badge,
    required this.badgeVariant,
    required this.removeLabel,
  });

  final HarmonyContact contact;
  final String badge;
  final HarmonyBadgeVariant badgeVariant;
  final String removeLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                contact.initials,
                style: const TextStyle(
                  color: AppColors.accentBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contact.name, style: AppTypography.textTheme.bodyMedium),
                Text(
                  contact.phone,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          HarmonyBadge(label: badge, variant: badgeVariant),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.remove_circle_outline,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
