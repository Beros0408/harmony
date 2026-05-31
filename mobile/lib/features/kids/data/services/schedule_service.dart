import '../../../../core/services/harmony_services.dart';

/// Plage horaire de verrouillage automatique récupérée depuis le backend.
class LockSchedule {
  const LockSchedule({
    required this.id,
    required this.label,
    required this.startMinutes,
    required this.endMinutes,
    required this.daysOfWeek,
  });

  final String id;
  final String label;
  final int startMinutes; // minutes depuis minuit (ex : 21:00 → 1260)
  final int endMinutes;   // minutes depuis minuit (ex : 07:00 → 420)
  final List<int> daysOfWeek; // 1=lundi … 7=dimanche (identique à DateTime.weekday)
}

/// Vérifie si [now] (ou l'heure locale courante si null) tombe dans la plage [schedule].
///
/// Logique traversée de minuit (start > end, ex 21:00 → 07:00) :
///   - Si [now] >= start : on est dans la partie "avant minuit" → vérifier que
///     le jour COURANT est dans [daysOfWeek].
///   - Si [now] < end   : on est dans la partie "après minuit" → le blocage a
///     commencé la VEILLE → vérifier que le jour PRÉCÉDENT est dans [daysOfWeek].
bool isInSchedule(LockSchedule schedule, {DateTime? now}) {
  final t = now ?? DateTime.now();
  final nowMinutes = t.hour * 60 + t.minute;
  final currentDay = t.weekday; // 1=lundi … 7=dimanche

  final crossesMidnight = schedule.startMinutes > schedule.endMinutes;

  if (!crossesMidnight) {
    // Plage normale ex 09:00 → 17:00
    return schedule.daysOfWeek.contains(currentDay) &&
        nowMinutes >= schedule.startMinutes &&
        nowMinutes < schedule.endMinutes;
  } else {
    // Plage traversant minuit ex 21:00 → 07:00
    if (nowMinutes >= schedule.startMinutes) {
      // Partie avant minuit : le blocage s'applique au jour courant
      return schedule.daysOfWeek.contains(currentDay);
    } else if (nowMinutes < schedule.endMinutes) {
      // Partie après minuit : le blocage a commencé la veille
      final previousDay = currentDay == 1 ? 7 : currentDay - 1;
      return schedule.daysOfWeek.contains(previousDay);
    }
    return false;
  }
}

/// Récupère les plages horaires actives pour un enfant via GET /api/v1/schedules.
class ScheduleService {
  ScheduleService._();
  static final ScheduleService instance = ScheduleService._();

  Future<List<LockSchedule>> getActiveSchedules(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<List<dynamic>>(
      '/api/v1/schedules',
      queryParameters: {'child_id': childId},
    );

    final list = response.data ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .where((m) => m['active'] == true)
        .map((m) => LockSchedule(
              id: m['id'] as String,
              label: (m['label'] as String?) ?? '',
              startMinutes: _parseMinutes(m['start_time'] as String),
              endMinutes: _parseMinutes(m['end_time'] as String),
              daysOfWeek: (m['days_of_week'] as List<dynamic>)
                  .map((d) => d as int)
                  .toList(),
            ),)
        .toList();
  }

  /// Convertit "HH:MM" ou "HH:MM:SS" en minutes depuis minuit.
  static int _parseMinutes(String timeStr) {
    final parts = timeStr.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
