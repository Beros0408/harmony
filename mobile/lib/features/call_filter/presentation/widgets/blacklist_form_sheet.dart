import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/core/constants/app_colors.dart';
import 'package:harmony/core/constants/app_spacing.dart';
import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';
import 'package:harmony/features/call_filter/data/repositories/blacklist_repository.dart';
import 'package:harmony/features/call_filter/logic/blacklist_cubit.dart';
import 'package:harmony/features/contacts/data/models/native_contact.dart';
import 'package:harmony/features/contacts/data/repositories/native_contacts_repository.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:harmony/shared/widgets/harmony_button.dart';
import 'package:harmony/shared/widgets/harmony_search_bar.dart';
import 'package:harmony/shared/widgets/harmony_text_field.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Shows the add/edit bottom sheet.
/// Pass [entry] to open in edit mode; omit for add mode.
Future<void> showBlacklistFormSheet({
  required BuildContext context,
  BlacklistEntry? entry,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => BlocProvider.value(
      value: context.read<BlacklistCubit>(),
      child: _BlacklistFormSheet(entry: entry),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _BlacklistFormSheet extends StatefulWidget {
  const _BlacklistFormSheet({this.entry});

  final BlacklistEntry? entry;

  @override
  State<_BlacklistFormSheet> createState() => _BlacklistFormSheetState();
}

class _BlacklistFormSheetState extends State<_BlacklistFormSheet> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _labelCtrl;
  late BlockReason _reason;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController(text: widget.entry?.phoneNumber ?? '');
    _labelCtrl = TextEditingController(text: widget.entry?.label ?? '');
    _reason = widget.entry?.reason ?? BlockReason.spam;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromContacts() async {
    final contact = await showModalBottomSheet<NativeContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ContactPickerSheet(),
    );
    if (contact != null && contact.phone != null && mounted) {
      _phoneCtrl.text = contact.phone!;
      if (_labelCtrl.text.isEmpty) {
        _labelCtrl.text = contact.displayName;
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo = BlacklistRepository.instance;
    final now = DateTime.now();

    if (_isEditing) {
      final updated = widget.entry!.copyWith(
        label: _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
        reason: _reason,
        updatedAt: now,
      );
      await context.read<BlacklistCubit>().updateEntry(updated);
    } else {
      final normalized = repo.normalizePhoneNumber(_phoneCtrl.text.trim());
      final entry = BlacklistEntry(
        id: _uuid.v4(),
        phoneNumber: normalized,
        label: _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
        reason: _reason,
        createdAt: now,
        updatedAt: now,
      );
      await context.read<BlacklistCubit>().addEntry(entry);
    }

    if (mounted) Navigator.of(context).pop();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Numéro requis';
    final repo = BlacklistRepository.instance;
    final normalized = repo.normalizePhoneNumber(value.trim());
    if (!repo.isValidPhoneNumber(normalized)) {
      return 'Numéro invalide (ex. +33 6 12 34 56 78)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              _isEditing ? l10n.blacklistEditTitle : l10n.blacklistAddTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Phone number
            HarmonyTextField(
              controller: _phoneCtrl,
              label: l10n.blacklistPhoneLabel,
              hint: l10n.blacklistPhoneHint,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: _isEditing ? null : _validatePhone,
            ),
            if (!_isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: _pickFromContacts,
                icon: const Icon(Icons.contacts_outlined, size: 16),
                label: Text(l10n.blacklistPickFromContacts),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // Optional label
            HarmonyTextField(
              controller: _labelCtrl,
              label: l10n.blacklistLabelHint,
              prefixIcon: Icons.label_outline,
            ),
            const SizedBox(height: AppSpacing.md),

            // Reason
            Text(
              l10n.blacklistReasonLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ReasonSelector(
              selected: _reason,
              onChanged: (r) => setState(() => _reason = r),
              l10n: l10n,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Save
            SizedBox(
              width: double.infinity,
              child: HarmonyButton(
                label: l10n.blacklistSaveButton,
                onPressed: _save,
                isLoading: _saving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reason selector ──────────────────────────────────────────────────────

class _ReasonSelector extends StatelessWidget {
  const _ReasonSelector({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  final BlockReason selected;
  final ValueChanged<BlockReason> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final reasons = [
      (BlockReason.spam, l10n.blacklistReasonSpam, AppColors.accentRed),
      (
        BlockReason.telemarketing,
        l10n.blacklistReasonTelemarketing,
        AppColors.accentAmber,
      ),
      (
        BlockReason.harassment,
        l10n.blacklistReasonHarassment,
        AppColors.accentPurple,
      ),
      (BlockReason.other, l10n.blacklistReasonOther, AppColors.textMuted),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      children: reasons.map((r) {
        final isSelected = selected == r.$1;
        return ChoiceChip(
          label: Text(r.$2),
          selected: isSelected,
          onSelected: (_) => onChanged(r.$1),
          selectedColor: r.$3.withValues(alpha: 0.18),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? r.$3 : AppColors.textSecondary,
          ),
          side: BorderSide(
            color: isSelected ? r.$3 : AppColors.borderDefault,
          ),
          backgroundColor: Colors.transparent,
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

// ─── Contact picker bottom sheet ──────────────────────────────────────────────

class _ContactPickerSheet extends StatefulWidget {
  const _ContactPickerSheet();

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  List<NativeContact> _contacts = [];
  List<NativeContact> _filtered = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final repo = NativeContactsRepository.instance;
      final granted = await repo.hasPermission() || await repo.requestPermission();
      if (!granted) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final contacts = await repo.fetchAll();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _filtered = contacts;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String query) {
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _filtered = _contacts;
      } else {
        final q = query.toLowerCase();
        _filtered = _contacts
            .where(
              (c) =>
                  c.displayName.toLowerCase().contains(q) ||
                  (c.phone?.contains(q) ?? false),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: HarmonySearchBar(
              hintText: 'Rechercher un contact...',
              autofocus: true,
              onChanged: _onSearch,
            ),
          ),
          Flexible(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxxl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxxl),
                        child: Text(
                          'Aucun contact',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final c = _filtered[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.accentBlue.withValues(alpha: 0.12),
                              child: Text(
                                c.initials,
                                style: const TextStyle(
                                  color: AppColors.accentBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            title: Text(c.displayName),
                            subtitle: c.phone != null ? Text(c.phone!) : null,
                            onTap: () => Navigator.of(context).pop(c),
                          );
                        },
                      ),
          ),
          SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
        ],
      ),
    );
  }
}
