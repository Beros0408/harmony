import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Règle de filtrage synchronisée avec le moteur natif (Android Kotlin / iOS CallKit).
enum CallRuleType { whitelist, blacklist, mode, blockHours }

class CallRule {
  const CallRule({required this.type, this.phoneNumber, this.value, this.start, this.end});

  final CallRuleType type;
  final String? phoneNumber;
  final String? value; // pour type=mode : 'normal', 'focus', 'night', 'work', 'weekend', 'emergency'
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

/// Entrée du journal des appels bloqués (Android uniquement).
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

/// Pont Flutter ↔ natif cross-platform pour le filtrage d'appels.
///
/// Android : MethodChannel "com.kimiacare.app/call_filter" → CallScreeningService Kotlin
/// iOS     : MethodChannel "com.kimiacare.app/call_filter_ios" → CXCallDirectoryProvider Swift
class CallFilterChannel {
  static const _androidChannel = MethodChannel('com.kimiacare.app/call_filter');
  static const _iosChannel = MethodChannel('com.kimiacare.app/call_filter_ios');

  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  // ──────────────────────────────── Android ────────────────────────────────

  /// Vérifie si Harmony est le CallScreeningService par défaut (Android uniquement).
  static Future<bool> isDefaultScreeningApp() async {
    if (_isIOS) return false;
    try {
      final result = await _androidChannel.invokeMethod<bool>('isDefaultScreeningApp');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Demande à l'utilisateur de définir Harmony comme app de filtrage par défaut (Android).
  static Future<void> requestScreeningRole() async {
    if (_isIOS) return;
    try {
      await _androidChannel.invokeMethod<void>('requestScreeningRole');
    } on PlatformException catch (e) {
      assert(e.code.isNotEmpty);
    }
  }

  /// Synchronise les règles de filtrage avec le moteur Kotlin natif (Android).
  static Future<void> syncRules(List<CallRule> rules) async {
    if (_isIOS) return;
    final payload = rules.map((r) => r.toJson()).toList();
    await _androidChannel.invokeMethod<void>('syncRules', {'rules': payload});
  }

  /// Récupère l'historique des appels bloqués (Android uniquement).
  static Future<List<BlockedCallEntry>> getBlockedCalls() async {
    if (_isIOS) return [];
    try {
      final result = await _androidChannel.invokeListMethod<Map<Object?, Object?>>('getBlockedCalls');
      return result?.map(BlockedCallEntry.fromJson).toList() ?? [];
    } on PlatformException {
      return [];
    }
  }

  /// Efface le journal des appels bloqués (Android uniquement).
  static Future<void> clearBlockedCalls() async {
    if (_isIOS) return;
    try {
      await _androidChannel.invokeMethod<void>('clearBlockedCalls');
    } on PlatformException {
      return;
    }
  }

  // ──────────────────────────────── iOS ────────────────────────────────────

  /// Vérifie si l'extension CallDirectory est activée dans Réglages (iOS uniquement).
  static Future<bool> isExtensionEnabled() async {
    if (!_isIOS) return false;
    try {
      final result = await _iosChannel.invokeMethod<bool>('isExtensionEnabled');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Déclenche le rechargement de l'extension (iOS uniquement).
  static Future<void> reloadExtension() async {
    if (!_isIOS) return;
    try {
      await _iosChannel.invokeMethod<void>('reloadExtension');
    } on PlatformException {
      return;
    }
  }

  /// Synchronise blacklist + whitelist dans les UserDefaults partagés et recharge l'extension (iOS).
  static Future<void> syncRulesToExtension({
    required List<String> blacklist,
    required List<String> whitelist,
  }) async {
    if (!_isIOS) return;
    try {
      await _iosChannel.invokeMethod<void>('syncRulesToExtension', {
        'blacklist': blacklist,
        'whitelist': whitelist,
      });
    } on PlatformException {
      return;
    }
  }

  /// Ouvre les Réglages iOS (iOS uniquement).
  static Future<void> openSettings() async {
    if (!_isIOS) return;
    try {
      await _iosChannel.invokeMethod<void>('openSettings');
    } on PlatformException {
      return;
    }
  }
}
