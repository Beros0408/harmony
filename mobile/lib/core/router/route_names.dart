class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String security = '/security';
  static const String family = '/family';
  static const String fitness = '/fitness';
  static const String agenda = '/agenda';
  static const String modes = '/modes';
  static const String contacts = '/contacts';
  static const String voicemail = '/voicemail';
  static const String callLog = '/call-log';
  static const String settings = '/settings';
  static const String blacklist = '/blacklist';

  // Sprint 4 — Agenda
  static const String agendaEvent = '/agenda/event';
  static const String agendaEventEdit = '/agenda/event/edit';
  static const String agendaTasks = '/agenda/tasks';
  static const String agendaGoogle = '/agenda/google';

  // Sprint 6 — Messages
  static const String messages = '/messages';

  // Sprint A — Appairage parent/enfant
  static const String addChildPairing = '/parental/add-child';

  // Sprint 3 — Parental
  static const String childDetail = '/parental/child';
  static const String safeZones = '/parental/zones';
  static const String safeZoneEditor = '/parental/zones/edit';
  static const String sosActive = '/parental/sos/active';
  static const String sosHistory = '/parental/sos/history';

  // Sprint 8 — Paywall
  static const String paywall = '/paywall';
  static const String subscriptionStatus = '/subscription';

  // Mini-Sprint Visuels — Méditation
  static const String meditation = '/meditation';

  // Hotfix v2.2.4 — Détail d'un message
  static const String messageDetail = '/message-detail';

  // Sprint Auth — Connexion / Inscription parent
  static const String login = '/login';
  static const String register = '/register';

  // Sprint 5A — Temps d'écran parent
  static const String screenTimeSummary = '/parental/child/:id/screen-time';

  // Sprint 5B — Limites de temps d'écran parent
  static const String screenTimeLimits = '/parental/child/:id/screen-time/limits';

  // Sprint S16 — Onboarding parent (premier lancement)
  static const String onboarding = '/onboarding';

  // Sprint C1 — Filtrage des appels parent
  static const String callFilterRules = '/parental/child/:id/call-filter-rules';

  // Dev only — design system showcase (non indexée en production)
  static const String devComponents = '/dev/components';
}
