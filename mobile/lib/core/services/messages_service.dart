import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/messages/data/models/captured_message.dart';

/// Wrapper du MethodChannel "com.kimiacare.app/messages_filter".
/// Fait le pont entre Flutter et le plugin Kotlin MessagesFilterPlugin.
class MessagesService {
  MessagesService._();

  static final MessagesService instance = MessagesService._();

  static const _channel = MethodChannel('com.kimiacare.app/messages_filter');

  // ─── Listener access ───────────────────────────────────────────────────────

  /// Vérifie si le NotificationListenerService est activé.
  Future<bool> isListenerEnabled() async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesService.isListenerEnabled()');
    try {
      final result = await _channel.invokeMethod<bool>('isNotificationListenerEnabled');
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] isListenerEnabled → $result');
      return result ?? false;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] isListenerEnabled PlatformException: ${e.code} ${e.message}');
      return false;
    }
  }

  /// Ouvre les paramètres système d'accès aux notifications.
  Future<void> requestAccess() async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesService.requestAccess()');
    try {
      await _channel.invokeMethod<void>('requestNotificationListenerAccess');
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] requestAccess PlatformException: ${e.code} ${e.message}');
      rethrow;
    }
  }

  // ─── SMS permission (Android runtime) ─────────────────────────────────────

  /// Vérifie si READ_SMS est accordée sans afficher de popup système.
  Future<bool> hasSmsPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      // Sur iOS, READ_SMS n'existe pas — on considère que la permission est OK.
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] hasSmsPermission: non-Android → true (no-op)');
      return true;
    }
    final status = await Permission.sms.status;
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] hasSmsPermission: ${status.name}');
    return status.isGranted;
  }

  /// Demande READ_SMS au runtime (Android 6+).
  /// Retourne true si accordée, false si refusée ou bannie définitivement.
  Future<bool> requestSmsPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] requestSmsPermission: non-Android → granted (no-op)');
      return true;
    }
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] requestSmsPermission: affichage popup système Android…');
    final status = await Permission.sms.request();
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] requestSmsPermission: ${status.name}');
    return status.isGranted;
  }

  // ─── SMS ───────────────────────────────────────────────────────────────────

  /// Lit les SMS entrants depuis content://sms/inbox.
  Future<List<CapturedMessage>> readRecentSms({int limit = 50}) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesService.readRecentSms(limit=$limit)');
    try {
      final dynamic result = await _channel.invokeMethod<dynamic>(
        'readRecentSms',
        {'limit': limit},
      );
      final raw = (result as List<dynamic>).cast<Map<Object?, Object?>>();
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] readRecentSms → ${raw.length} SMS');
      return raw.map((m) => CapturedMessage.fromMap(_toStringMap(m))).toList();
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] readRecentSms PlatformException: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] readRecentSms exception: $e');
      rethrow;
    }
  }

  // ─── Notifications ─────────────────────────────────────────────────────────

  /// Retourne les notifications captées par HarmonyNotificationListener.
  Future<List<CapturedMessage>> getInterceptedNotifications() async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesService.getInterceptedNotifications()');
    try {
      final dynamic result =
          await _channel.invokeMethod<dynamic>('getInterceptedNotifications');
      final raw = (result as List<dynamic>).cast<Map<Object?, Object?>>();
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] getInterceptedNotifications → ${raw.length} notifications');
      return raw.map((m) => CapturedMessage.fromMap(_toStringMap(m))).toList();
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] getInterceptedNotifications PlatformException: ${e.code}');
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] getInterceptedNotifications exception: $e');
      rethrow;
    }
  }

  /// Convertit Map<Object?, Object?> en Map<String, dynamic> pour CapturedMessage.fromMap.
  static Map<String, dynamic> _toStringMap(Map<Object?, Object?> raw) =>
      raw.map((k, v) => MapEntry(k.toString(), v));
}
