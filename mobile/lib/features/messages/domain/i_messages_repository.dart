import '../data/models/captured_message.dart';
import '../data/models/message_rule.dart';

abstract interface class IMessagesRepository {
  /// Vérifie si le NotificationListenerService est activé dans les paramètres système.
  Future<bool> isListenerEnabled();

  /// Ouvre l'écran système d'accès aux notifications pour que l'utilisateur puisse activer Harmony.
  Future<void> requestListenerAccess();

  /// Lit les SMS récents depuis le ContentProvider Android (content://sms/inbox).
  Future<List<CapturedMessage>> readRecentSms({int limit = 50});

  /// Retourne les notifications WhatsApp/Signal/Telegram captées en mémoire.
  Future<List<CapturedMessage>> getInterceptedNotifications();

  /// Retourne l'union des SMS + notifications, triée par date décroissante.
  Future<List<CapturedMessage>> getAllMessages({int limit = 100});

  /// Charge toutes les règles de filtrage sauvegardées.
  Future<List<MessageRule>> getRules();

  /// Ajoute une règle de filtrage.
  Future<void> addRule(MessageRule rule);

  /// Met à jour une règle existante.
  Future<void> updateRule(MessageRule rule);

  /// Supprime une règle.
  Future<void> deleteRule(String id);
}
