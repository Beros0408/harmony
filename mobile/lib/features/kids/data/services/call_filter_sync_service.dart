import 'package:flutter/foundation.dart';

import '../../../../core/services/harmony_services.dart';
import '../../../call_filter/data/native/call_filter_channel.dart';

/// Synchronise les règles de filtrage d'appels depuis le backend vers le moteur
/// natif [CallDecisionEngine] (Android).
///
/// Chaque appel à [sync] effectue un remplacement **total et atomique** de l'état
/// natif : whitelist + blacklist + mode + plages horaires sont reconstruits depuis
/// le snapshot backend. Le backend fait autorité ; aucune règle locale ne subsiste.
///
/// Déclenché par [CommandPollingService] toutes les 15 s (et immédiatement au
/// démarrage). Ne touche pas [BlacklistRepository] ni la base SQLCipher locale.
class CallFilterSyncService {
  CallFilterSyncService._();
  static final CallFilterSyncService instance = CallFilterSyncService._();

  /// Récupère GET /api/v1/call-filter-rules/{childId} et pousse le jeu complet
  /// de règles vers [CallFilterChannel.syncRules].
  ///
  /// Silencieux en cas d'erreur réseau : les règles précédentes restent actives
  /// jusqu'au prochain tick.
  Future<void> sync(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>('/api/v1/call-filter-rules/$childId');

    final data = response.data;
    if (data == null) return;

    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    final rulesRaw = data['rules'] as List<dynamic>? ?? [];

    final listMode = settings['list_mode'] as String? ?? 'blacklist';
    final blockStart = (settings['block_hour_start'] as num?)?.toInt() ?? 22;
    final blockEnd = (settings['block_hour_end'] as num?)?.toInt() ?? 7;

    final rules = <CallRule>[];

    for (final raw in rulesRaw) {
      final entry = raw as Map<String, dynamic>;
      final listType = entry['list_type'] as String? ?? '';
      final phoneNumber = entry['phone_number'] as String? ?? '';
      if (phoneNumber.isEmpty) continue;

      if (listType == 'blacklist') {
        rules.add(CallRule(type: CallRuleType.blacklist, phoneNumber: phoneNumber));
      } else if (listType == 'whitelist') {
        rules.add(CallRule(type: CallRuleType.whitelist, phoneNumber: phoneNumber));
      }
    }

    // Mode global : blacklist → normal (bloque les numéros listés)
    //              whitelist → emergency (bloque tout sauf numéros listés)
    rules.add(CallRule(type: CallRuleType.mode, value: _translateMode(listMode)));

    // Plages horaires toujours transmises pour garder le moteur cohérent
    rules.add(CallRule(type: CallRuleType.blockHours, start: blockStart, end: blockEnd));

    await CallFilterChannel.syncRules(rules);

    debugPrint(
      '[CallFilterSyncService] sync — '
      '${rules.where((r) => r.type == CallRuleType.blacklist).length} blacklist, '
      '${rules.where((r) => r.type == CallRuleType.whitelist).length} whitelist, '
      'mode=${_translateMode(listMode)}, '
      'blockHours=$blockStart-$blockEnd',
    );
  }

  /// Traduit le mode backend en valeur attendue par [CallDecisionEngine].
  static String _translateMode(String listMode) => switch (listMode) {
        'whitelist' => 'emergency',
        _ => 'normal',
      };
}
