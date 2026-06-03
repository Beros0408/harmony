import 'dart:io';

import 'package:flutter/services.dart';

/// Pont Dart ↔ UsageStatsPlugin Kotlin.
/// Lit l'usage applicatif journalier via PACKAGE_USAGE_STATS.
/// Android uniquement — méthodes neutres sur les autres plateformes.
class UsageStatsService {
  UsageStatsService._();
  static final UsageStatsService instance = UsageStatsService._();

  static const MethodChannel _channel = MethodChannel('harmony/usage_stats');

  /// Retourne true si l'utilisateur a accordé PACKAGE_USAGE_STATS.
  Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('isPermissionGranted') ?? false;
  }

  /// Ouvre les réglages Android USAGE_ACCESS (fire-and-forget).
  /// Rappeler [isPermissionGranted] après le retour au premier plan.
  Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod<void>('requestPermission');
  }

  /// Retourne l'usage de chaque app depuis 00:00 jusqu'à maintenant.
  /// Lance une [PlatformException] si la permission n'est pas accordée.
  Future<List<UsageEntry>> getDailyUsage() async {
    if (!Platform.isAndroid) return [];
    final raw = await _channel.invokeMethod<List<dynamic>>('getDailyUsage');
    if (raw == null) return [];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map((m) => UsageEntry.fromMap(Map<String, dynamic>.from(m)))
        .toList();
  }
}

/// Entrée d'usage pour une application donnée.
class UsageEntry {
  const UsageEntry({
    required this.packageName,
    required this.durationSeconds,
    this.appLabel,
    this.category,
  });

  final String packageName;
  final String? appLabel;
  final String? category;
  final int durationSeconds;

  factory UsageEntry.fromMap(Map<String, dynamic> m) => UsageEntry(
        packageName: m['package_name'] as String,
        appLabel: m['app_label'] as String?,
        category: m['category'] as String?,
        durationSeconds: (m['duration_seconds'] as num).toInt(),
      );
}
