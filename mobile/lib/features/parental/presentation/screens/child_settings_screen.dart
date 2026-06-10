import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_text_field.dart';
import '../../data/models/child_profile.dart';
import '../../logic/child_profile_cubit.dart';

/// Écran de configuration d'un profil enfant (nom, âge, couleur avatar).
class ChildSettingsScreen extends StatefulWidget {
  const ChildSettingsScreen({super.key, required this.childId});
  final String childId;

  @override
  State<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends State<ChildSettingsScreen> {
  final _nameController = TextEditingController();
  int _age = 8;
  Color _avatarColor = AppColors.accentBlue;
  ChildProfile? _profile;

  // Palette de couleurs avatar disponibles
  static const _avatarColors = [
    AppColors.accentBlue,
    AppColors.accentGreen,
    AppColors.accentPurple,
    AppColors.accentAmber,
    AppColors.accentRed,
    Color(0xFF00BCD4), // cyan
    Color(0xFFFF5722), // deep orange
  ];

  // Plages horaires d'usage autorisées par jour de semaine (mock persistance Sprint 8)
  final Map<int, bool> _allowedDays = {
    DateTime.monday: true,
    DateTime.tuesday: true,
    DateTime.wednesday: true,
    DateTime.thursday: true,
    DateTime.friday: true,
    DateTime.saturday: true,
    DateTime.sunday: true,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  void _loadProfile() {
    final cubitState = context.read<ChildProfileCubit>().state;
    if (cubitState is ChildProfileLoaded) {
      final p = cubitState.profiles
          .where((c) => c.id == widget.childId)
          .firstOrNull;
      if (p != null && mounted) {
        setState(() {
          _profile = p;
          _nameController.text = p.name;
          _age = p.age;
          _avatarColor = p.avatarColor;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(title: l10n.childSettingsTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Avatar preview
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _avatarColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _avatarColor.withValues(alpha: 0.4), width: 3),
              ),
              child: Center(
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text[0].toUpperCase()
                      : '?',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: _avatarColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Nom
          HarmonyTextField(
            controller: _nameController,
            label: 'Prénom',
            hint: 'Ex: Lucas',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Âge
          HarmonyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Âge', style: Theme.of(context).textTheme.labelLarge),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _age > 3
                          ? () => setState(() => _age--)
                          : null,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$_age ans',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _age < 18
                          ? () => setState(() => _age++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Couleur avatar
          HarmonyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Couleur de l\'avatar',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _avatarColors.map((color) {
                    final isSelected = _avatarColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _avatarColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Jours autorisés
          HarmonyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jours d\'utilisation autorisés',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                ..._allowedDays.entries.map((e) => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_dayName(e.key)),
                      value: e.value,
                      onChanged: (v) =>
                          setState(() => _allowedDays[e.key] = v),
                      activeColor: AppColors.accentBlue,
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Contacts d'urgence SOS
          HarmonyCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.sos, color: AppColors.accentRed),
              title: Text(l10n.sosContactsTitle,
                  style: Theme.of(context).textTheme.labelLarge),
              subtitle: Text('Contacts appelés en cas d\'urgence'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(
                '${RouteNames.childDetail}/${widget.childId}/sos-contacts',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Filtrage des appels
          HarmonyCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.call_outlined, color: AppColors.accentBlue),
              title: Text(l10n.callFilterRulesTitle,
                  style: Theme.of(context).textTheme.labelLarge),
              subtitle: Text(l10n.callFilterRulesSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(
                '${RouteNames.childDetail}/${widget.childId}/call-filter-rules',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Sauvegarder
          HarmonyButton(
            label: l10n.blacklistSaveButton,
            onPressed: _save,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Supprimer profil
          if (_profile != null)
            TextButton(
              onPressed: _confirmDelete,
              child: Text(
                'Supprimer ce profil',
                style: TextStyle(color: AppColors.accentRed),
              ),
            ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;
    if (_profile == null) return;
    final updated = _profile!.copyWith(
      name: _nameController.text.trim(),
      age: _age,
      avatarColor: _avatarColor,
    );
    context.read<ChildProfileCubit>().add(updated);
    Navigator.of(context).pop();
  }

  void _confirmDelete() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce profil ?'),
        content: Text('Le profil de ${_profile!.name} sera supprimé définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ChildProfileCubit>().remove(_profile!.id);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer', style: TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }

  String _dayName(int day) => switch (day) {
        DateTime.monday => 'Lundi',
        DateTime.tuesday => 'Mardi',
        DateTime.wednesday => 'Mercredi',
        DateTime.thursday => 'Jeudi',
        DateTime.friday => 'Vendredi',
        DateTime.saturday => 'Samedi',
        DateTime.sunday => 'Dimanche',
        _ => '',
      };
}
