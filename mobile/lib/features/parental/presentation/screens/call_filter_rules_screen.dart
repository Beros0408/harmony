import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';
import '../../../../shared/widgets/harmony_text_field.dart';
import '../../data/models/call_filter_rule.dart';
import '../../data/services/call_filter_api_service.dart';

class CallFilterRulesScreen extends StatefulWidget {
  const CallFilterRulesScreen({super.key, required this.childId});
  final String childId;

  @override
  State<CallFilterRulesScreen> createState() => _CallFilterRulesScreenState();
}

class _CallFilterRulesScreenState extends State<CallFilterRulesScreen> {
  List<CallFilterRule> _rules = [];
  CallFilterSettings _settings = CallFilterSettings.defaults;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result =
          await CallFilterApiService.instance.getRules(widget.childId);
      if (!mounted) return;
      setState(() {
        _settings = result.settings;
        _rules = result.rules;
      });
    } catch (_) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context)!.callFilterLoadError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeMode(ListMode mode) async {
    final previous = _settings;
    setState(() => _settings = CallFilterSettings(listMode: mode));
    try {
      await CallFilterApiService.instance
          .updateSettings(widget.childId, mode);
    } catch (_) {
      if (!mounted) return;
      setState(() => _settings = previous);
      _showError(AppLocalizations.of(context)!.callFilterSaveError);
    }
  }

  Future<void> _addRule(String phone, String? label) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      await CallFilterApiService.instance.addRule(
        widget.childId,
        phone,
        _settings.listMode,
        label: label,
      );
      await _load();
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e.response?.statusCode == 409
          ? l10n.callFilterDuplicateError
          : l10n.callFilterSaveError);
    } catch (_) {
      if (!mounted) return;
      _showError(l10n.callFilterSaveError);
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(int i) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.callFilterDeleteConfirm),
        content: Text(l10n.callFilterDeleteContent),
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
      await CallFilterApiService.instance.deleteRule(_rules[i].id);
      await _load();
    } catch (_) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context)!.callFilterDeleteError);
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.accentRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: l10n.callFilterRulesTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_outlined),
            tooltip: l10n.callFilterAddRule,
            onPressed: () => _showAddSheet(context),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // ── Sélecteur de mode ──────────────────────────────────────
                HarmonyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mode',
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ListMode>(
                          segments: [
                            ButtonSegment(
                              value: ListMode.blacklist,
                              label: Text(l10n.callFilterModeBlacklist),
                              icon: const Icon(Icons.block_outlined, size: 16),
                            ),
                            ButtonSegment(
                              value: ListMode.whitelist,
                              label: Text(l10n.callFilterModeWhitelist),
                              icon: const Icon(
                                  Icons.check_circle_outline, size: 16),
                            ),
                          ],
                          selected: {_settings.listMode},
                          onSelectionChanged: (s) => _changeMode(s.first),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _settings.listMode == ListMode.blacklist
                            ? l10n.callFilterModeBlacklistDesc
                            : l10n.callFilterModeWhitelistDesc,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Bannière info ──────────────────────────────────────────
                HarmonyCard(
                  padding: AppSpacing.md,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.accentAmber, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.callFilterInfoBanner,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Liste des règles ───────────────────────────────────────
                if (_rules.isEmpty)
                  HarmonyEmptyState(
                    icon: Icons.phone_callback_outlined,
                    title: l10n.callFilterRulesEmpty,
                    subtitle: l10n.callFilterRulesEmptyDesc,
                    cta: l10n.callFilterAddRule,
                    onCtaTap: () => _showAddSheet(context),
                  )
                else ...[
                  ..._rules.asMap().entries.map((e) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CallFilterRuleTile(
                          rule: e.value,
                          onRemove: () => _confirmDelete(e.key),
                        ),
                      )),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: () => _showAddSheet(context),
                    icon: const Icon(Icons.add_outlined),
                    label: Text(l10n.callFilterAddRule),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ],
            ),
    );
  }

  Future<void> _showAddSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRuleSheet(
        listMode: _settings.listMode,
        onAdd: _addRule,
      ),
    );
  }
}

// ─── Tuile règle ─────────────────────────────────────────────────────────────

class _CallFilterRuleTile extends StatelessWidget {
  const _CallFilterRuleTile({required this.rule, required this.onRemove});
  final CallFilterRule rule;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBlacklist = rule.listType == ListMode.blacklist;
    final color = isBlacklist ? AppColors.accentRed : AppColors.accentGreen;

    return HarmonyCard(
      child: Row(
        children: [
          // Badge type
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.smRadius,
            ),
            child: Text(
              isBlacklist
                  ? l10n.callFilterTypeBlacklist
                  : l10n.callFilterTypeWhitelist,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Numéro + label optionnel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.phoneNumber,
                    style: Theme.of(context).textTheme.labelLarge),
                if (rule.label != null && rule.label!.isNotEmpty)
                  Text(rule.label!,
                      style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),

          // Supprimer
          IconButton(
            icon: const Icon(Icons.close,
                size: 18, color: AppColors.accentRed),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

// ─── Feuille d'ajout ─────────────────────────────────────────────────────────

class _AddRuleSheet extends StatefulWidget {
  const _AddRuleSheet({required this.listMode, required this.onAdd});
  final ListMode listMode;
  final Future<void> Function(String phone, String? label) onAdd;

  @override
  State<_AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends State<_AddRuleSheet> {
  final _phoneController = TextEditingController();
  final _labelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final label = _labelController.text.trim();
    await widget.onAdd(
      _phoneController.text.trim(),
      label.isEmpty ? null : label,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.outline,
                        borderRadius: AppRadius.smRadius,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text(l10n.callFilterAddRule,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.lg),

                  HarmonyTextField(
                    controller: _phoneController,
                    label: l10n.callFilterPhoneLabel,
                    hint: l10n.callFilterPhoneHint,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.callFilterPhoneEmptyError
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  HarmonyTextField(
                    controller: _labelController,
                    label: l10n.callFilterLabelOptional,
                    hint: 'Ex: Démarcheur, École...',
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  FilledButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add_outlined),
                    label: Text(l10n.callFilterAddRule),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
