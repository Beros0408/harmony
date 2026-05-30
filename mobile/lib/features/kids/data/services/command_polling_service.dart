import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/harmony_services.dart';
import 'device_admin_service.dart';

/// Représentation d'une commande reçue du backend.
class DeviceCommand {
  const DeviceCommand({required this.id, required this.command});
  final String id;
  final String command;
}

/// Service singleton de polling (intervalle 15 s) qui récupère les commandes
/// en attente pour cet appareil enfant et les exécute localement.
///
/// Démarré depuis [KidsAdminScreen] ou [main_kids.dart] (si déjà appairé).
/// Arrêté proprement via [stop].
class CommandPollingService {
  CommandPollingService._();
  static final CommandPollingService instance = CommandPollingService._();

  static const _pollInterval = Duration(seconds: 15);

  Timer? _timer;
  String? _childId;
  bool _running = false;

  bool get isRunning => _running;

  /// Démarre le polling pour [childId]. Idempotent : si déjà démarré pour le
  /// même child_id, ne fait rien.
  void start(String childId) {
    if (_running && _childId == childId) return;
    stop(); // arrête proprement avant de redémarrer si le child_id change
    _childId = childId;
    _running = true;
    // Premier poll immédiat, puis toutes les 15 s
    _poll();
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
    debugPrint('[CommandPollingService] polling démarré pour child=$childId');
  }

  /// Arrête le polling et libère le timer.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    debugPrint('[CommandPollingService] polling arrêté');
  }

  Future<void> _poll() async {
    final childId = _childId;
    if (childId == null) return;

    try {
      final commands = await _fetchPendingCommands(childId);
      for (final cmd in commands) {
        await _executeCommand(cmd);
      }
    } catch (e) {
      // Ne jamais planter l'app en cas d'erreur réseau — simple log
      debugPrint('[CommandPollingService] erreur poll: $e');
    }
  }

  /// Appelle GET /api/v1/commands/pending?child_id=...
  Future<List<DeviceCommand>> _fetchPendingCommands(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<List<dynamic>>(
      '/api/v1/commands/pending',
      queryParameters: {'child_id': childId},
    );

    final list = response.data ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((m) => DeviceCommand(
              id: m['id'] as String,
              command: m['command'] as String,
            ),)
        .toList();
  }

  /// Exécute une commande et l'acquitte auprès du backend.
  Future<void> _executeCommand(DeviceCommand cmd) async {
    if (cmd.command == 'lock') {
      try {
        await DeviceAdminService.instance.lockNow();
        debugPrint('[CommandPollingService] écran verrouillé (commande ${cmd.id})');
      } catch (e) {
        // Admin inactif ou autre erreur : on acquitte quand même pour éviter
        // de rejouer indéfiniment une commande non exécutable.
        debugPrint('[CommandPollingService] lockNow échoué: $e');
      }
      // Acquittement dans tous les cas
      await _ackCommand(cmd.id);
    }
  }

  /// Appelle POST /api/v1/commands/{id}/ack
  Future<void> _ackCommand(String commandId) async {
    try {
      await HarmonyServices.dioClient.instance
          .post<void>('/api/v1/commands/$commandId/ack');
      debugPrint('[CommandPollingService] commande $commandId acquittée');
    } catch (e) {
      debugPrint('[CommandPollingService] ack échoué pour $commandId: $e');
    }
  }
}
