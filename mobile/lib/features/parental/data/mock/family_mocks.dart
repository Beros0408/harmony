import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/harmony_status_dot.dart';

class ChildProfile {
  final String name;
  final int age;
  final String letter;
  final Color avatarColor;
  final HarmonyStatus status;
  final String statusText;
  final int score;
  const ChildProfile({
    required this.name,
    required this.age,
    required this.letter,
    required this.avatarColor,
    required this.status,
    required this.statusText,
    required this.score,
  });
}

class SafeZone {
  final IconData icon;
  final String name;
  final String detail;
  final HarmonyStatus status;
  const SafeZone({
    required this.icon,
    required this.name,
    required this.detail,
    required this.status,
  });
}

const kChildren = [
  ChildProfile(
    name: 'Lucas',
    age: 12,
    letter: 'L',
    avatarColor: AppColors.accentBlue,
    status: HarmonyStatus.online,
    statusText: "À l'école",
    score: 92,
  ),
  ChildProfile(
    name: 'Emma',
    age: 9,
    letter: 'E',
    avatarColor: AppColors.accentPurple,
    status: HarmonyStatus.warning,
    statusText: 'À la maison',
    score: 78,
  ),
];

const kSafeZones = [
  SafeZone(
    icon: Icons.home,
    name: 'Maison',
    detail: 'Rayon 250m · Activée 24h/24',
    status: HarmonyStatus.online,
  ),
  SafeZone(
    icon: Icons.school,
    name: 'École Jules Ferry',
    detail: 'Rayon 100m · Lun-Ven 8h-17h',
    status: HarmonyStatus.online,
  ),
  SafeZone(
    icon: Icons.sports_soccer,
    name: 'Stade municipal',
    detail: 'Rayon 150m · Mer-Sam après-midi',
    status: HarmonyStatus.warning,
  ),
];

const kDailyLimits = [
  (label: 'Temps d\'écran aujourd\'hui', value: '1h47 / 2h30', progress: 0.73),
  (label: 'Distance de la maison', value: '1.2km / 2km autorisés', progress: 0.60),
];
