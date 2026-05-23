import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FilterMode {
  final String title;
  final IconData icon;
  final Color color;
  const FilterMode({required this.title, required this.icon, required this.color});
}

class FilterRule {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool defaultEnabled;
  const FilterRule({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.defaultEnabled,
  });
}

class BlockedCall {
  final String number;
  final String detail;
  const BlockedCall({required this.number, required this.detail});
}

const kSecurityKpis = (blocked: 127, rules: 5, accuracy: 98);

const kFilterModes = [
  FilterMode(title: 'Mode Normal', icon: Icons.shield_outlined, color: AppColors.accentBlue),
  FilterMode(title: 'Mode Focus', icon: Icons.do_not_disturb_on_outlined, color: AppColors.accentAmber),
  FilterMode(title: 'Mode Nuit', icon: Icons.nightlight_outlined, color: AppColors.accentPurple),
];

const kFilterRules = [
  FilterRule(
    icon: Icons.help_outline,
    title: 'Numéros inconnus',
    subtitle: 'Bloquer tous les appels non identifiés',
    defaultEnabled: true,
  ),
  FilterRule(
    icon: Icons.do_not_disturb,
    title: 'Démarchage',
    subtitle: 'Détection IA des appels commerciaux',
    defaultEnabled: true,
  ),
  FilterRule(
    icon: Icons.block,
    title: 'Liste noire personnelle',
    subtitle: '12 numéros',
    defaultEnabled: true,
  ),
  FilterRule(
    icon: Icons.public,
    title: 'Numéros étrangers',
    subtitle: 'Indicatifs hors France',
    defaultEnabled: false,
  ),
  FilterRule(
    icon: Icons.verified_user,
    title: 'Whitelist familiale',
    subtitle: '8 contacts toujours autorisés',
    defaultEnabled: true,
  ),
];

const kRecentBlockedCalls = [
  BlockedCall(number: '+33 6 12 34 56 78', detail: 'Démarchage · il y a 2h'),
  BlockedCall(number: 'Numéro inconnu', detail: 'Inconnu · il y a 5h'),
  BlockedCall(number: '+33 1 23 45 67 89', detail: 'Liste noire · hier 18h47'),
];
