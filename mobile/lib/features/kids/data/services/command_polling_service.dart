import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/harmony_services.dart';
import 'blocked_calls_upload_service.dart';
import 'call_filter_sync_service.dart';
import 'content_filter_service.dart';
import 'device_admin_service.dart';
import 'schedule_service.dart';
import 'screen_time_blocking_service.dart';
import 'unlink_request_service.dart';

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

  /// Dernier statut de déliage connu — évite de refirer le callback à chaque tick.
  String _lastUnlinkStatus = 'none';

  /// Rappelé avec le request_id quand le parent approuve le déliage.
  void Function(String requestId)? onUnlinkApproved;

  /// Rappelé quand le parent refuse le déliage.
  void Function()? onUnlinkRejected;

  bool get isRunning => _running;

  /// Démarre le polling pour [childId]. Idempotent : si déjà démarré pour le
  /// même child_id, ne fait rien.
  void start(String childId) {
    if (_running && _childId == childId) return;
    stop(); // arrête proprement avant de redémarrer si le child_id change
    _childId = childId;
    _running = true;
    _lastUnlinkStatus = 'none';
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

  /// Détache les callbacks de déliage — à appeler dans dispose() de l'écran.
  void clearUnlinkCallbacks() {
    onUnlinkApproved = null;
    onUnlinkRejected = null;
  }

  Future<void> _poll() async {
    final childId = _childId;
    if (childId == null) return;

    try {
      // B2 : exécuter les commandes distantes en attente
      final commands = await _fetchPendingCommands(childId);
      for (final cmd in commands) {
        await _executeCommand(cmd);
      }

      // B3 : vérifier si on est dans une plage horaire de verrouillage
      await _checkSchedules(childId);

      // Sprint C : synchroniser l'état du VPN DNS avec le backend
      await _checkContentFilter(childId);

      // Sprint Délier : détecter une approbation ou un refus parent
      await _checkUnlinkStatus(childId);

      // Sprint Filtrage B1 : synchroniser les règles d'appels depuis le backend
      await _checkCallFilterRules(childId);

      // Sprint Filtrage B2 : remonter les appels bloqués vers le backend
      await _uploadBlockedCalls(childId);
    } catch (e) {
      // Ne jamais planter l'app en cas d'erreur réseau — simple log
      debugPrint('[CommandPollingService] erreur poll: $e');
    }
  }

  /// Récupère les plages actives et verrouille si l'heure locale tombe dedans.
  Future<void> _checkSchedules(String childId) async {
    try {
      final schedules = await ScheduleService.instance.getActiveSchedules(childId);
      final shouldLock = schedules.any((s) => isInSchedule(s));
      if (shouldLock) {
        final adminActive = await DeviceAdminService.instance.isAdminActive();
        if (adminActive) {
          await DeviceAdminService.instance.lockNow();
          debugPrint('[CommandPollingService] verrouillage automatique (plage horaire)');
        }
      }
    } catch (e) {
      // Pas de plage ou réseau coupé — pas de verrouillage, pas de crash
      debugPrint('[CommandPollingService] erreur checkSchedules: $e');
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
      await _ackCommand(cmd.id);
    } else if (cmd.command == 'screen_pause') {
      // Pause distante parent — active l'overlay bienveillant immédiatement
      await ScreenTimeBlockingService.instance.activateRemotePause();
      debugPrint('[CommandPollingService] pause distante activée (commande ${cmd.id})');
      await _ackCommand(cmd.id);
    } else if (cmd.command == 'screen_resume') {
      // Levée de pause distante parent
      await ScreenTimeBlockingService.instance.deactivateRemotePause();
      debugPrint('[CommandPollingService] pause distante levée (commande ${cmd.id})');
      await _ackCommand(cmd.id);
    }
  }

  /// Lit l'état du filtrage sur le backend et démarre/arrête le VPN DNS en
  /// conséquence. Idempotent : ne redémarre pas si déjà dans le bon état.
  Future<void> _checkContentFilter(String childId) async {
    try {
      final response = await HarmonyServices.dioClient.instance
          .get<Map<String, dynamic>>(
        '/api/v1/content-filter',
        queryParameters: {'child_id': childId},
      );
      final enabled = (response.data?['enabled'] as bool?) ?? false;
      final running = await ContentFilterService.instance.isFiltering();

      if (enabled && !running) {
        final status = await ContentFilterService.instance.startFiltering();
        debugPrint('[CommandPollingService] filtrage démarré: $status');
      } else if (!enabled && running) {
        await ContentFilterService.instance.stopFiltering();
        debugPrint('[CommandPollingService] filtrage arrêté');
      }
    } catch (e) {
      debugPrint('[CommandPollingService] erreur checkContentFilter: $e');
    }
  }

  /// Vérifie si le parent a approuvé ou refusé la demande de déliage.
  /// Ne déclenche le callback qu'une seule fois par changement de statut.
  Future<void> _checkUnlinkStatus(String childId) async {
    try {
      final result = await UnlinkRequestService.instance.getStatus(childId);
      final newStatus = result.status;

      // Ne réagit que si le statut a changé depuis le dernier tick
      if (newStatus == _lastUnlinkStatus) return;
      _lastUnlinkStatus = newStatus;

      if (newStatus == 'approved' && result.requestId != null) {
        debugPrint('[CommandPollingService] déliage approuvé, requestId=${result.requestId}');
        onUnlinkApproved?.call(result.requestId!);
      } else if (newStatus == 'rejected') {
        debugPrint('[CommandPollingService] déliage refusé');
        onUnlinkRejected?.call();
      }
    } catch (e) {
      // Erreur réseau sur /unlink/status — pas bloquant, on réessaie au prochain tick
      debugPrint('[CommandPollingService] erreur checkUnlinkStatus: $e');
    }
  }

  /// Remonte les appels bloqués depuis le moteur natif vers le backend.
  Future<void> _uploadBlockedCalls(String childId) async {
    try {
      await BlockedCallsUploadService.instance.upload(childId);
    } catch (e) {
      debugPrint('[CommandPollingService] erreur uploadBlockedCalls: $e');
    }
  }

  /// Récupère le snapshot de filtrage d'appels et le pousse vers le moteur natif.
  Future<void> _checkCallFilterRules(String childId) async {
    try {
      await CallFilterSyncService.instance.sync(childId);
    } catch (e) {
      debugPrint('[CommandPollingService] erreur checkCallFilterRules: $e');
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
