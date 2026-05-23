import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/harmony_status_dot.dart';

enum ChildLocationKey { school, home }

enum SafeZoneKey { home, school, stadium }

enum LimitKey { screenTime, distance }

class ChildProfile {
  final String name;
  final int age;
  final String letter;
  final Color avatarColor;
  final HarmonyStatus status;
  final ChildLocationKey locationKey;
  final int score;
  const ChildProfile({
    required this.name,
    required this.age,
    required this.letter,
    required this.avatarColor,
    required this.status,
    required this.locationKey,
    required this.score,
  });
}

class SafeZone {
  final SafeZoneKey key;
  final IconData icon;
  final HarmonyStatus status;
  const SafeZone({required this.key, required this.icon, required this.status});
}

const kChildren = [
  ChildProfile(
    name: 'Lucas',
    age: 12,
    letter: 'L',
    avatarColor: AppColors.accentBlue,
    status: HarmonyStatus.online,
    locationKey: ChildLocationKey.school,
    score: 92,
  ),
  ChildProfile(
    name: 'Emma',
    age: 9,
    letter: 'E',
    avatarColor: AppColors.accentPurple,
    status: HarmonyStatus.warning,
    locationKey: ChildLocationKey.home,
    score: 78,
  ),
];

const kSafeZones = [
  SafeZone(key: SafeZoneKey.home, icon: Icons.home, status: HarmonyStatus.online),
  SafeZone(key: SafeZoneKey.school, icon: Icons.school, status: HarmonyStatus.online),
  SafeZone(key: SafeZoneKey.stadium, icon: Icons.sports_soccer, status: HarmonyStatus.warning),
];

const kDailyLimits = [
  (key: LimitKey.screenTime, value: '1h47 / 2h30', progress: 0.73),
  (key: LimitKey.distance, value: '1.2km / 2km', progress: 0.60),
];
