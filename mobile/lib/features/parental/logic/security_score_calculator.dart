import '../data/models/geofence_event.dart';
import '../data/models/security_score.dart';
import '../data/models/sos_alert.dart';

/// Calcule un score de sécurité 0-100 pour un enfant donné.
/// Pondération :
///   40 pts — % du temps dans zones autorisées
///   30 pts — respect des plages horaires
///   20 pts — aucune alerte SOS dans les 7 derniers jours
///   10 pts — aucun trajet anormal (hors scope Sprint 3 → bonus par défaut)
class SecurityScoreCalculator {
  const SecurityScoreCalculator();

  SecurityScore calculate({
    required String childId,
    required List<GeofenceEvent> recentEvents,
    required List<SosAlert> recentSosAlerts,
  }) {
    final now = DateTime.now();

    // 40 pts — proportion d'événements "entrée" vs "sortie" non justifiée
    final exits = recentEvents.where((e) => e.type == GeofenceEventType.exit).length;
    final entries = recentEvents.where((e) => e.type == GeofenceEventType.entry).length;
    int zoneScore;
    if (entries + exits == 0) {
      zoneScore = 40; // pas de données → score neutre
    } else {
      final compliance = entries / (entries + exits).clamp(1, double.infinity);
      zoneScore = (compliance * 40).round();
    }

    // 30 pts — aucun exit en dehors des plages (approximation Sprint 3 : bonus plein si < 2 exits)
    final scheduleScore = exits <= 1 ? 30 : exits <= 3 ? 20 : 10;

    // 20 pts — aucune alerte SOS dans les 7 derniers jours
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final recentSos = recentSosAlerts.where(
      (s) => s.timestamp.isAfter(sevenDaysAgo) && s.childId == childId,
    );
    final sosScore = recentSos.isEmpty ? 20 : 0;

    // 10 pts — trajet normal (Sprint 3 : toujours accordé)
    const tripScore = 10;

    final total = (zoneScore + scheduleScore + sosScore + tripScore).clamp(0, 100);

    return SecurityScore(
      childId: childId,
      value: total,
      lastUpdate: now,
    );
  }
}
