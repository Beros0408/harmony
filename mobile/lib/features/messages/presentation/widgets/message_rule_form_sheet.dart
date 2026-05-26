import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../features/contacts/data/models/native_contact.dart';
import '../../../../features/contacts/data/repositories/native_contacts_repository.dart';
import '../../../../shared/widgets/harmony_search_bar.dart';
import '../../../../shared/widgets/harmony_text_field.dart';
import '../../data/models/captured_message.dart';
import '../../data/models/message_rule.dart';
import '../../logic/messages_cubit.dart';

class MessageRuleFormSheet extends StatefulWidget {
  const MessageRuleFormSheet({super.key, this.rule});

  /// Si non-null, on est en mode édition.
  final MessageRule? rule;

  @override
  State<MessageRuleFormSheet> createState() => _MessageRuleFormSheetState();
}

class _MessageRuleFormSheetState extends State<MessageRuleFormSheet> {
  late RuleType _ruleType;
  late RuleAction _action;
  late TextEditingController _valueCtrl;
  late List<MessageSource> _sources;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _isEditing = rule != null;
    _ruleType = rule?.ruleType ?? RuleType.keyword;
    _action = rule?.action ?? RuleAction.block;
    _valueCtrl = TextEditingController(text: rule?.value ?? '');
    _sources = List.of(rule?.sources ?? []);
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromContacts() async {
    final contact = await showModalBottomSheet<NativeContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ContactPickerSheet(),
    );
    if (contact != null && mounted) {
      _valueCtrl.text = contact.phone ?? contact.displayName;
    }
  }

  void _submit() {
    final value = _valueCtrl.text.trim();
    if (value.isEmpty && _ruleType != RuleType.schedule) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez une valeur')),
      );
      return;
    }

    final rule = MessageRule(
      id: widget.rule?.id ?? '',
      ruleType: _ruleType,
      value: value,
      action: _action,
      sources: List.unmodifiable(_sources),
    );

    final cubit = context.read<MessagesCubit>();
    if (_isEditing) {
      cubit.updateRule(rule);
    } else {
      cubit.addRule(rule);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
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
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Modifier la règle' : 'Nouvelle règle',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Type de règle
                  Text('Type de règle', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<RuleType>(
                    segments: RuleType.values
                        .map(
                          (t) => ButtonSegment(
                            value: t,
                            label: Text(t.displayName),
                          ),
                        )
                        .toList(),
                    selected: {_ruleType},
                    onSelectionChanged: (s) =>
                        setState(() => _ruleType = s.first),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Valeur
                  if (_ruleType != RuleType.schedule) ...[
                    HarmonyTextField(
                      controller: _valueCtrl,
                      label: _ruleType == RuleType.contact
                          ? 'Numéro ou nom'
                          : 'Mot-clé',
                      hint: _ruleType == RuleType.contact
                          ? '+336...'
                          : 'spam, pub, promo...',
                      keyboardType: _ruleType == RuleType.contact
                          ? TextInputType.phone
                          : TextInputType.text,
                    ),
                    if (_ruleType == RuleType.contact) ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        onPressed: _pickFromContacts,
                        icon: const Icon(Icons.contacts_outlined, size: 16),
                        label: const Text('Choisir depuis mes contacts'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentBlue,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  if (_ruleType == RuleType.schedule) ...[
                    Text(
                      'Plage horaire : la règle s\'applique entre ces heures',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: HarmonyTextField(
                            controller: _valueCtrl,
                            label: 'Plage (ex: 22-7)',
                            hint: 'startHour-endHour',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Action
                  Text('Action', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SegmentedButton<RuleAction>(
                    segments: RuleAction.values
                        .map(
                          (a) => ButtonSegment(
                            value: a,
                            label: Text(a.displayName),
                            icon: Icon(
                              a == RuleAction.block
                                  ? Icons.block_outlined
                                  : Icons.check_circle_outline,
                            ),
                          ),
                        )
                        .toList(),
                    selected: {_action},
                    onSelectionChanged: (s) =>
                        setState(() => _action = s.first),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Sources
                  Text('Sources', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Laisser vide pour toutes les sources',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: MessageSource.values.map((s) {
                      final selected = _sources.contains(s);
                      return FilterChip(
                        label: Text(s.displayName),
                        selected: selected,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _sources.add(s);
                          } else {
                            _sources.remove(s);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Bouton de soumission
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(_isEditing ? 'Enregistrer' : 'Ajouter la règle'),
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

// ─── ContactPickerSheet (réutilisé depuis Sprint 5) ──────────────────────────

class _ContactPickerSheet extends StatefulWidget {
  const _ContactPickerSheet();

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  late Future<List<NativeContact>> _contactsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _contactsFuture = NativeContactsRepository.instance.fetchAll();
  }

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
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
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
              hintText: 'Rechercher...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<NativeContact>>(
              future: _contactsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final contacts = (snap.data ?? [])
                    .where((c) =>
                        _query.isEmpty ||
                        c.displayName
                            .toLowerCase()
                            .contains(_query.toLowerCase()) ||
                        (c.phone?.contains(_query) ?? false))
                    .toList();
                if (contacts.isEmpty) {
                  return const Center(child: Text('Aucun contact'));
                }
                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: contacts.length,
                  itemBuilder: (context, i) {
                    final c = contacts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.accentBlue.withValues(alpha: 0.12),
                        child: Text(
                          c.initials,
                          style:
                              const TextStyle(color: AppColors.accentBlue),
                        ),
                      ),
                      title: Text(c.displayName),
                      subtitle: c.phone != null ? Text(c.phone!) : null,
                      onTap: () => Navigator.of(context).pop(c),
                    );
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
