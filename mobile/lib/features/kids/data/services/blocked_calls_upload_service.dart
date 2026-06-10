import 'package:flutter/foundation.dart';

import '../../../../core/services/harmony_services.dart';
import '../../../call_filter/data/native/call_filter_channel.dart';

/// Remonte les appels bloqués par [CallDecisionEngine] vers le backend.
///
/// Stratégie :
///   - Pas de clear du [CallLogStore] natif (historique conservé pour l'UI).
///   - High-water mark en mémoire ([_lastUploadedMs]) : seuls les appels dont
///     le timestamp dépasse la dernière remontée réussie sont envoyés.
///   - Idempotence backend (ON CONFLICT DO NOTHING) : un re-upload éventuel
///     au redémarrage (HWM remis à 0) est absorbé sans doublon.
class BlockedCallsUploadService {
  BlockedCallsUploadService._();
  static final BlockedCallsUploadService instance = BlockedCallsUploadService._();

  /// Timestamp epoch ms du dernier appel uploadé avec succès.
  /// 0 = aucun upload effectué → premier tick envoie tout le store.
  int _lastUploadedMs = 0;

  /// Récupère les appels bloqués depuis le moteur natif, filtre les nouveaux
  /// (timestamp > [_lastUploadedMs]), les poste en batch, puis avance la HWM.
  /// Ne fait rien si le store est vide ou si tout a déjà été uploadé.
  Future<void> upload(String childId) async {
    final allCalls = await CallFilterChannel.getBlockedCalls();
    if (allCalls.isEmpty) return;

    final newCalls = allCalls
        .where((e) => e.timestamp.millisecondsSinceEpoch > _lastUploadedMs)
        .toList();

    if (newCalls.isEmpty) {
      debugPrint('[BlockedCallsUploadService] aucun nouvel appel à uploader');
      return;
    }

    final payload = newCalls
        .map((e) => <String, dynamic>{
              'phone_number': e.phoneNumber,
              'blocked_at': e.timestamp.toUtc().toIso8601String(),
              'latency_ms': e.latencyMs,
            })
        .toList();

    await HarmonyServices.dioClient.instance.post<dynamic>(
      '/api/v1/blocked-calls/$childId',
      data: {'calls': payload},
    );

    // Avance la HWM au timestamp le plus récent du batch uploadé
    var maxMs = 0;
    for (final e in newCalls) {
      final ms = e.timestamp.millisecondsSinceEpoch;
      if (ms > maxMs) maxMs = ms;
    }
    _lastUploadedMs = maxMs;

    debugPrint(
      '[BlockedCallsUploadService] ${newCalls.length} appels uploadés '
      'pour $childId, hwm=$maxMs',
    );
  }
}
