// Données mock Sprint B — gardées pour compatibilité tests existants.
// Les vrais modèles sont dans data/models/ (ChildProfile, SafeZone, etc.).
// Ce fichier n'est plus utilisé par les écrans depuis Sprint 3.

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/harmony_status_dot.dart';

enum MockChildLocationKey { school, home }

enum MockSafeZoneKey { home, school, stadium }

enum LimitKey { screenTime, distance }

class MockChildData {
  final String name;
  final int age;
  final String letter;
  final Color avatarColor;
  final HarmonyStatus status;
  final MockChildLocationKey locationKey;
  final int score;
  const MockChildData({
    required this.name,
    required this.age,
    required this.letter,
    required this.avatarColor,
    required this.status,
    required this.locationKey,
    required this.score,
  });
}

class MockSafeZoneData {
  final MockSafeZoneKey key;
  final IconData icon;
  final HarmonyStatus status;
  const MockSafeZoneData({required this.key, required this.icon, required this.status});
}

const kMockChildren = [
  MockChildData(
    name: 'Lucas',
    age: 12,
    letter: 'L',
    avatarColor: AppColors.accentBlue,
    status: HarmonyStatus.online,
    locationKey: MockChildLocationKey.school,
    score: 92,
  ),
  MockChildData(
    name: 'Emma',
    age: 9,
    letter: 'E',
    avatarColor: AppColors.accentPurple,
    status: HarmonyStatus.warning,
    locationKey: MockChildLocationKey.home,
    score: 78,
  ),
];

const kMockSafeZones = [
  MockSafeZoneData(key: MockSafeZoneKey.home, icon: Icons.home, status: HarmonyStatus.online),
  MockSafeZoneData(key: MockSafeZoneKey.school, icon: Icons.school, status: HarmonyStatus.online),
  MockSafeZoneData(key: MockSafeZoneKey.stadium, icon: Icons.sports_soccer, status: HarmonyStatus.warning),
];

const kDailyLimits = [
  (key: LimitKey.screenTime, value: '1h47 / 2h30', progress: 0.73),
  (key: LimitKey.distance, value: '1.2km / 2km', progress: 0.60),
];
