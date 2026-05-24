import 'package:flutter/services.dart';

/// Règle de filtrage synchronisée avec le moteur Kotlin natif.
enum CallRuleType { whitelist, blacklist, mode, blockHours }

class CallRule {
  const CallRule({required this.type, this.phoneNumber, this.value, this.start, this.end});

  final CallRuleType type;
  final String? phoneNumber;
  final String? value; // pour type=mode : 'normal', 'focus', 'night', 'emergency'
  final int? start;   // pour type=blockHours
  final int? end;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (value != null) 'value': value,
        if (start != null) 'start': start,
        if (end != null) 'end': end,
      };
}

/// Entrée du journal des appels bloqués.
class BlockedCallEntry {
  const BlockedCallEntry({
    required this.phoneNumber,
    required this.timestamp,
    required this.latencyMs,
  });

  final String phoneNumber;
  final DateTime timestamp;
  final int latencyMs;

  factory BlockedCallEntry.fromJson(Map<Object?, Object?> map) => BlockedCallEntry(
        phoneNumber: map['phoneNumber'] as String? ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (map['timestamp'] as int?) ?? 0,
        ),
        latencyMs: (map['latencyMs'] as int?) ?? 0,
      );
}

/// Pont Flutter ↔ Android natif pour le filtrage d'appels.
/// Channel : "com.harmony.app/call_filter"
class CallFilterChannel {
  static const _channel = MethodChannel('com.harmony.app/call_filter');

  /// Vérifie si Harmony est le CallScreeningService par défaut du système.
  static Future<bool> isDefaultScreeningApp() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDefaultScreeningApp');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Demande à l'utilisateur de définir Harmony comme app de filtrage par défaut.
  /// Fire-and-forget — appeler [isDefaultScreeningApp] ensuite pour confirmer.
  static Future<void> requestScreeningRole() async {
    try {
      await _channel.invokeMethod<void>('requestScreeningRole');
    } on PlatformException catch (e) {
      // L'appareil ne supporte pas le rôle (< Android 10) — ignorer
      assert(e.code.isNotEmpty); // évite unused warning
    }
  }

  /// Synchronise les règles de filtrage avec le moteur Kotlin natif.
  static Future<void> syncRules(List<CallRule> rules) async {
    final payload = rules.map((r) => r.toJson()).toList();
    await _channel.invokeMethod<void>('syncRules', {'rules': payload});
  }

  /// Récupère l'historique des appels bloqués depuis le journal natif.
  static Future<List<BlockedCallEntry>> getBlockedCalls() async {
    try {
      final result = await _channel.invokeListMethod<Map<Object?, Object?>>('getBlockedCalls');
      return result?.map(BlockedCallEntry.fromJson).toList() ?? [];
    } on PlatformException {
      return [];
    }
  }

  /// Efface le journal des appels bloqués.
  static Future<void> clearBlockedCalls() async {
    try {
      await _channel.invokeMethod<void>('clearBlockedCalls');
    } on PlatformException {
      return;
    }
  }
}
