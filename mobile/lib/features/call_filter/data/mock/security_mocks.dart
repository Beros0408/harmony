import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum FilterModeType { normal, focus, night }

enum FilterRuleType { unknownNumbers, spam, blacklist, foreign, whitelist }

class FilterMode {
  final FilterModeType type;
  final IconData icon;
  final Color color;
  const FilterMode({required this.type, required this.icon, required this.color});
}

class FilterRule {
  final FilterRuleType type;
  final IconData icon;
  final bool defaultEnabled;
  const FilterRule({required this.type, required this.icon, required this.defaultEnabled});
}

class BlockedCall {
  final String number;
  final String detail;
  const BlockedCall({required this.number, required this.detail});
}

const kSecurityKpis = (blocked: 127, rules: 5, accuracy: 98);

const kFilterModes = [
  FilterMode(type: FilterModeType.normal, icon: Icons.shield_outlined, color: AppColors.accentBlue),
  FilterMode(type: FilterModeType.focus, icon: Icons.do_not_disturb_on_outlined, color: AppColors.accentAmber),
  FilterMode(type: FilterModeType.night, icon: Icons.nightlight_outlined, color: AppColors.accentPurple),
];

const kFilterRules = [
  FilterRule(type: FilterRuleType.unknownNumbers, icon: Icons.help_outline, defaultEnabled: true),
  FilterRule(type: FilterRuleType.spam, icon: Icons.do_not_disturb, defaultEnabled: true),
  FilterRule(type: FilterRuleType.blacklist, icon: Icons.block, defaultEnabled: true),
  FilterRule(type: FilterRuleType.foreign, icon: Icons.public, defaultEnabled: false),
  FilterRule(type: FilterRuleType.whitelist, icon: Icons.verified_user, defaultEnabled: true),
];

const kRecentBlockedCalls = [
  BlockedCall(number: '+33 6 12 34 56 78', detail: 'Démarchage · il y a 2h'),
  BlockedCall(number: 'Numéro inconnu', detail: 'Inconnu · il y a 5h'),
  BlockedCall(number: '+33 1 23 45 67 89', detail: 'Liste noire · hier 18h47'),
];
