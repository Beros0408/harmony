import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AgendaEvent {
  final String title;
  final String timeRange;
  final Color accentColor;
  final IconData detailIcon;
  final String detailText;
  const AgendaEvent({
    required this.title,
    required this.timeRange,
    required this.accentColor,
    required this.detailIcon,
    required this.detailText,
  });
}

class DayMode {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool defaultEnabled;
  const DayMode({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.defaultEnabled,
  });
}

const kDayModes = [
  DayMode(
    title: 'Concentration',
    subtitle: 'Notifications limitées',
    icon: Icons.headphones,
    color: AppColors.accentBlue,
    defaultEnabled: true,
  ),
  DayMode(
    title: 'Sommeil',
    subtitle: 'Programmé 22h-7h',
    icon: Icons.bedtime,
    color: AppColors.accentPurple,
    defaultEnabled: false,
  ),
];

const kTodayEvents = [
  AgendaEvent(
    title: 'Réunion équipe produit',
    timeRange: '14h00–15h00 · Bureau',
    accentColor: AppColors.accentBlue,
    detailIcon: Icons.people,
    detailText: '5 participants',
  ),
  AgendaEvent(
    title: 'Dîner avec parents',
    timeRange: '19h30–21h00 · À la maison',
    accentColor: AppColors.accentGreen,
    detailIcon: Icons.location_on,
    detailText: 'Maison',
  ),
  AgendaEvent(
    title: 'Cours de yoga',
    timeRange: '18h00–19h00',
    accentColor: AppColors.accentAmber,
    detailIcon: Icons.fitness_center,
    detailText: 'Studio Mahalo',
  ),
];
