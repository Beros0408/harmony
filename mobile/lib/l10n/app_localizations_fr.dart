// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'KimiaCare';

  @override
  String get dashboardTitle => 'KimiaCare';

  @override
  String get dashboardWelcomeWave => 'Bienvenue 👋';

  @override
  String get dashboardAllServicesActive => 'Tous les services actifs';

  @override
  String get dashboardSectionModules => 'MES MODULES';

  @override
  String get moduleSecurityTitle => 'Sécurité';

  @override
  String get moduleSecuritySubtitle => 'Filtrage actif';

  @override
  String get moduleSecurityBadge => 'actif';

  @override
  String get moduleFamilyTitle => 'Famille';

  @override
  String get moduleFamilySubtitle => 'Contrôle parental';

  @override
  String moduleFamilyBadgeProfiles(int count) {
    return '$count profils';
  }

  @override
  String get moduleFitnessTitle => 'Fitness';

  @override
  String moduleFitnessSubtitle(int current, int goal) {
    return '$current / $goal pas';
  }

  @override
  String get moduleFitnessBadge => 'en cours';

  @override
  String get moduleAgendaTitle => 'Agenda';

  @override
  String moduleAgendaSubtitle(int count) {
    return '$count événements';
  }

  @override
  String get moduleAgendaBadge => 'aujourd\'hui';

  @override
  String get navBack => 'Retour';

  @override
  String get navBackToDashboard => 'Retour au tableau de bord';

  @override
  String get securityScreenTitle => 'Sécurité & Filtrage';

  @override
  String get securityStatsBlocked => 'Bloqués';

  @override
  String get securityStatsRules => 'Règles';

  @override
  String get securityStatsPrecision => 'Précision';

  @override
  String get securitySectionActiveMode => 'MODE ACTIF';

  @override
  String get securityModeNormal => 'Mode Normal';

  @override
  String get securityModeFocus => 'Mode Focus';

  @override
  String get securityModeNight => 'Mode Nuit';

  @override
  String get securitySectionRules => 'RÈGLES DE FILTRAGE';

  @override
  String get securityRuleUnknownNumbers => 'Numéros inconnus';

  @override
  String get securityRuleUnknownNumbersDesc =>
      'Bloquer tous les appels non identifiés';

  @override
  String get securityRuleSpam => 'Démarchage';

  @override
  String get securityRuleSpamDesc => 'Détection IA des appels commerciaux';

  @override
  String get securityRuleBlacklist => 'Liste noire personnelle';

  @override
  String securityRuleBlacklistDesc(int count) {
    return '$count numéros';
  }

  @override
  String get securityRuleForeign => 'Numéros étrangers';

  @override
  String get securityRuleForeignDesc => 'Indicatifs hors France';

  @override
  String get securityRuleWhitelist => 'Whitelist familiale';

  @override
  String securityRuleWhitelistDesc(int count) {
    return '$count contacts toujours autorisés';
  }

  @override
  String get securitySectionRecentBlocked => 'DERNIERS APPELS BLOQUÉS';

  @override
  String get securitySeeAll => 'Voir tout';

  @override
  String get familyScreenTitle => 'Famille & Contrôle parental';

  @override
  String get familySectionChildren => 'MES ENFANTS';

  @override
  String familyChildAge(String name, int age) {
    return '$name, $age ans';
  }

  @override
  String get familyStatusAtSchool => 'À l\'école';

  @override
  String get familyStatusAtHome => 'À la maison';

  @override
  String familyScoreLabel(int value) {
    return 'Score $value';
  }

  @override
  String familyChildDetailsToast(String name) {
    return 'Détails de $name à venir au Sprint 2';
  }

  @override
  String get familySectionLocation => 'LOCALISATION EN TEMPS RÉEL';

  @override
  String get familyMapPlaceholderTitle => 'Carte interactive à venir';

  @override
  String get familyMapPlaceholderSubtitle => 'Google Maps — Sprint 2';

  @override
  String get familySectionZones => 'ZONES AUTORISÉES';

  @override
  String get familyZoneHome => 'Maison';

  @override
  String get familyZoneHomeDesc => 'Rayon 250m · Activée 24h/24';

  @override
  String get familyZoneSchool => 'École Jules Ferry';

  @override
  String get familyZoneSchoolDesc => 'Rayon 100m · Lun-Ven 8h-17h';

  @override
  String get familyZoneStadium => 'Stade municipal';

  @override
  String get familyZoneStadiumDesc => 'Rayon 150m · Mer-Sam après-midi';

  @override
  String get familySectionLimits => 'LIMITES QUOTIDIENNES';

  @override
  String get familyLimitScreen => 'Temps d\'écran aujourd\'hui';

  @override
  String get familyLimitDistance => 'Distance de la maison';

  @override
  String get fitnessScreenTitle => 'Fitness & Performance';

  @override
  String get fitnessSectionToday => 'AUJOURD\'HUI';

  @override
  String get fitnessSteps => 'Pas';

  @override
  String fitnessStepsGoal(int goal) {
    return '/ $goal obj.';
  }

  @override
  String get fitnessCalories => 'Calories';

  @override
  String get fitnessCaloriesUnit => 'kcal';

  @override
  String get fitnessDistance => 'Distance';

  @override
  String get fitnessDistanceUnit => 'km';

  @override
  String get fitnessHeartRate => 'BPM moyen';

  @override
  String get fitnessHeartRateUnit => 'bpm';

  @override
  String get fitnessSectionWeekly => 'ACTIVITÉ HEBDOMADAIRE';

  @override
  String get fitnessWeekdayMon => 'L';

  @override
  String get fitnessWeekdayTue => 'M';

  @override
  String get fitnessWeekdayWed => 'M';

  @override
  String get fitnessWeekdayThu => 'J';

  @override
  String get fitnessWeekdayFri => 'V';

  @override
  String get fitnessWeekdaySat => 'S';

  @override
  String get fitnessWeekdaySun => 'D';

  @override
  String get fitnessSectionRecords => 'MES RECORDS';

  @override
  String get fitnessRecordLongestWalk => 'Plus longue marche';

  @override
  String get fitnessRecordLongestWalkDesc => '12.5 km · il y a 2 semaines';

  @override
  String get fitnessRecordMostSteps => 'Plus de pas en 1 jour';

  @override
  String get fitnessRecordMostStepsDesc => '14 832 pas · il y a 1 mois';

  @override
  String get fitnessRecordFastestRun => 'Course la plus rapide';

  @override
  String get fitnessRecordFastestRunDesc => '5km en 28 min · il y a 3 jours';

  @override
  String get fitnessSectionSessions => 'DERNIÈRES SÉANCES';

  @override
  String get fitnessSessionWalk => 'Marche';

  @override
  String get fitnessSessionWalkDesc => '35min · 3.2km · hier 18h12';

  @override
  String get fitnessSessionRun => 'Course';

  @override
  String get fitnessSessionRunDesc => '28min · 5km · il y a 3 jours';

  @override
  String get fitnessSessionBike => 'Vélo';

  @override
  String get fitnessSessionBikeDesc => '1h12 · 18km · il y a 5 jours';

  @override
  String get agendaScreenTitle => 'Agenda & Planification';

  @override
  String get agendaDateToday => 'Aujourd\'hui';

  @override
  String get agendaNavigationToast => 'Navigation jour à venir';

  @override
  String get agendaSectionModes => 'MODES DU JOUR';

  @override
  String get agendaModeFocus => 'Concentration';

  @override
  String get agendaModeFocusDesc => 'Notifications limitées';

  @override
  String get agendaModeSleep => 'Sommeil';

  @override
  String get agendaModeSleepDesc => 'Programmé 22h-7h';

  @override
  String get agendaSectionEvents => 'MES ÉVÉNEMENTS DU JOUR';

  @override
  String get agendaEventMeeting => 'Réunion équipe produit';

  @override
  String get agendaEventMeetingTime => '14h00–15h00 · Bureau';

  @override
  String agendaEventMeetingDetail(int count) {
    return '$count participants';
  }

  @override
  String get agendaEventDinner => 'Dîner avec parents';

  @override
  String get agendaEventDinnerTime => '19h30–21h00 · À la maison';

  @override
  String get agendaEventDinnerDetail => 'Maison';

  @override
  String get agendaEventYoga => 'Cours de yoga';

  @override
  String get agendaEventYogaTime => '18h00–19h00';

  @override
  String get agendaEventYogaDetail => 'Studio Mahalo';

  @override
  String get agendaCreateButton => 'Nouvel événement';

  @override
  String get agendaCreateToast => 'Création d\'événement à venir au Sprint 4';

  @override
  String get authWelcomeTitle => 'Bienvenue sur KimiaCare';

  @override
  String get authCreatePinTitle => 'Créer votre code PIN';

  @override
  String get authChoosePin => 'Choisissez un code à 4 chiffres';

  @override
  String get authConfirmPinTitle => 'Confirmez votre code PIN';

  @override
  String get authReenterPin => 'Saisissez à nouveau le code PIN';

  @override
  String get authEnterPin => 'Saisissez votre code PIN';

  @override
  String get authPinMismatch => 'Les codes ne correspondent pas';

  @override
  String get authIncorrectCode => 'Code incorrect';

  @override
  String authAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count essais restants',
      one: '1 essai restant',
    );
    return '$_temp0';
  }

  @override
  String get authBiometricSetupTitle => 'Activer la biométrie ?';

  @override
  String get authBiometricSetupDesc =>
      'Déverrouillez KimiaCare avec Face ID ou votre empreinte digitale.';

  @override
  String get authBiometricEnable => 'Activer';

  @override
  String get authBiometricLater => 'Plus tard';

  @override
  String get authBiometricSkip => 'Ignorer';

  @override
  String get emptyStateComingSoon => 'Bientôt disponible';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguagePortuguese => 'Português';

  @override
  String get settingsLanguageItalian => 'Italiano';

  @override
  String get settingsTheme => 'Apparence';

  @override
  String get settingsThemeSystem => 'Automatique';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get moduleContactsTitle => 'Contacts';

  @override
  String get moduleContactsSubtitle => 'Gestion des contacts';

  @override
  String moduleContactsBadge(int count) {
    return '$count contacts';
  }

  @override
  String get contactsScreenTitle => 'Contacts';

  @override
  String get contactsSectionWhitelist => 'LISTE BLANCHE';

  @override
  String get contactsSectionBlacklist => 'LISTE NOIRE';

  @override
  String get contactsAddContact => 'Ajouter un contact';

  @override
  String get contactsWhitelistBadge => 'autorisé';

  @override
  String get contactsBlacklistBadge => 'bloqué';

  @override
  String get contactsEmpty => 'Aucun contact';

  @override
  String get contactsRemove => 'Retirer';

  @override
  String get contactsPermissionTitle => 'Accès aux contacts requis';

  @override
  String get contactsPermissionSubtitle =>
      'KimiaCare a besoin de votre permission pour afficher votre carnet d\'adresses.';

  @override
  String get contactsPermissionCta => 'Autoriser l\'accès aux contacts';

  @override
  String get blacklistPickFromContacts => 'Choisir depuis mes contacts';

  @override
  String get voicemailScreenTitle => 'Messagerie vocale';

  @override
  String voicemailNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux messages',
      one: '1 nouveau message',
      zero: 'Aucun nouveau message',
    );
    return '$_temp0';
  }

  @override
  String voicemailTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages au total',
      one: '1 message au total',
    );
    return '$_temp0';
  }

  @override
  String get voicemailPushInfo => 'Simulation de push activée';

  @override
  String get voicemailMarkRead => 'Marquer comme lu';

  @override
  String get voicemailDelete => 'Supprimer';

  @override
  String get voicemailCallBack => 'Rappeler';

  @override
  String get voicemailUrgent => 'Urgent';

  @override
  String get voicemailNewMessageToastTitle => 'Nouveau message vocal';

  @override
  String voicemailNewMessageToastBody(String name) {
    return 'Message de $name';
  }

  @override
  String get voicemailViewButton => 'Voir';

  @override
  String get voicemailTranscriptionLabel => 'Transcription';

  @override
  String get voicemailExpandHint => 'Voir la transcription';

  @override
  String get voicemailMockNote =>
      'Transcriptions simulées — vraie STT au Sprint 5';

  @override
  String get voicemailPlay => 'Écouter';

  @override
  String get callScreeningEnableTitle => 'Activer la protection';

  @override
  String get callScreeningEnableDescription =>
      'Pour bloquer les appels indésirables, KimiaCare doit être votre application de filtrage par défaut';

  @override
  String get callScreeningEnableButton => 'Activer';

  @override
  String get callScreeningActiveStatus => 'Protection active';

  @override
  String get callLogScreenTitle => 'Journal des blocages';

  @override
  String get callLogFilterToday => 'Aujourd\'hui';

  @override
  String get callLogFilterWeek => 'Cette semaine';

  @override
  String get callLogFilterAll => 'Tout';

  @override
  String get callLogEmptyState => 'Aucun appel bloqué';

  @override
  String get callLogClearAllButton => 'Tout effacer';

  @override
  String get iosFilteringTitle => 'Filtrage iOS';

  @override
  String get iosFilteringInstructions =>
      'Pour activer le blocage d\'appels sur iOS, activez l\'extension dans Réglages.';

  @override
  String get iosFilteringStep1 =>
      'Ouvrez Réglages → Téléphone → Blocage et identification d\'appels';

  @override
  String get iosFilteringStep2 => 'Activez KimiaCare dans la liste';

  @override
  String get iosFilteringOpenSettingsButton => 'Ouvrir les réglages';

  @override
  String get outgoingCallAlertTitle => 'Appel potentiellement surtaxé';

  @override
  String outgoingCallAlertEstimatedCost(String cost) {
    return 'Coût estimé : $cost €/min';
  }

  @override
  String get outgoingCallAlertCancel => 'Annuler';

  @override
  String get outgoingCallAlertContinueButton => 'Continuer l\'appel';

  @override
  String get outgoingCallAlertDontAskAgain => 'Ne plus demander pour ce numéro';

  @override
  String get filterModeOff => 'Désactivé';

  @override
  String get filterModeNight => 'Nuit';

  @override
  String get filterModeWork => 'Travail';

  @override
  String get filterModeFocus => 'Focus';

  @override
  String get filterModeWeekend => 'Week-end';

  @override
  String get filterModeEmergency => 'Urgence';

  @override
  String get filterModeActivate => 'Activer';

  @override
  String get filterModeConfigure => 'Configurer';

  @override
  String get filterModeCurrentActive => 'Mode actif';

  @override
  String get blacklistScreenTitle => 'Liste noire';

  @override
  String get blacklistSearchHint => 'Rechercher un numéro ou une étiquette...';

  @override
  String get blacklistEmptyTitle => 'Aucun numéro bloqué';

  @override
  String get blacklistAddTitle => 'Ajouter un numéro';

  @override
  String get blacklistEditTitle => 'Modifier l\'entrée';

  @override
  String get blacklistPhoneLabel => 'Numéro de téléphone';

  @override
  String get blacklistPhoneHint => '+33 6 12 34 56 78';

  @override
  String get blacklistLabelHint => 'Étiquette (optionnel)';

  @override
  String get blacklistReasonLabel => 'Raison du blocage';

  @override
  String get blacklistSaveButton => 'Enregistrer';

  @override
  String get blacklistReasonSpam => 'Spam';

  @override
  String get blacklistReasonTelemarketing => 'Démarchage';

  @override
  String get blacklistReasonHarassment => 'Harcèlement';

  @override
  String get blacklistReasonOther => 'Autre';

  @override
  String get familyChildrenSection => 'MES ENFANTS';

  @override
  String get familyMapSection => 'LOCALISATION EN TEMPS RÉEL';

  @override
  String get familyZonesSection => 'ZONES AUTORISÉES';

  @override
  String get familyAddZoneFAB => 'Ajouter une zone';

  @override
  String get childDetailTitle => 'Détail de l\'enfant';

  @override
  String childAtZone(String name) {
    return 'Dans : $name';
  }

  @override
  String get childInTransit => 'En déplacement';

  @override
  String childSecurityScore(int value) {
    return 'Score $value';
  }

  @override
  String get zoneEditorAddTitle => 'Nouvelle zone';

  @override
  String get zoneEditorEditTitle => 'Modifier la zone';

  @override
  String get zoneFieldName => 'Nom de la zone';

  @override
  String get zoneFieldRadius => 'Rayon';

  @override
  String get zoneFieldIcon => 'Icône';

  @override
  String get zoneIconHome => 'Maison';

  @override
  String get zoneIconSchool => 'École';

  @override
  String get zoneIconSport => 'Sport';

  @override
  String get zoneIconOther => 'Autre';

  @override
  String get sosButtonLabel => 'SOS';

  @override
  String get sosHoldHint => 'Maintenez 3 secondes pour déclencher';

  @override
  String get sosActiveTitle => 'SOS ACTIF';

  @override
  String get sosActiveCountdown => 'Appel dans';

  @override
  String get sosActiveCancel => 'Annuler le SOS';

  @override
  String get sosCancelConfirm => 'Êtes-vous en sécurité ?';

  @override
  String get sosTriggerConfirmTitle => 'Envoyer une alerte SOS ?';

  @override
  String get sosTriggerConfirmMessage =>
      'Ton parent sera alerté immédiatement avec ta position.';

  @override
  String get sosTriggerConfirmCancel => 'Annuler';

  @override
  String get sosTriggerConfirmSend => 'Envoyer le SOS';

  @override
  String get sosSentSuccess => 'SOS envoyé, ton parent a été alerté';

  @override
  String get sosSentError =>
      'Impossible d\'envoyer le SOS, vérifie ta connexion';

  @override
  String get sosSectionTitle => 'ALERTES SOS';

  @override
  String get sosNoActive => 'Aucune alerte SOS — tout va bien.';

  @override
  String get sosAcknowledge => 'J\'ai vu — Acquitter';

  @override
  String sosPosition(String lat, String lon) {
    return 'Position : $lat, $lon';
  }

  @override
  String get sosViewOnMap => 'Voir sur la carte';

  @override
  String get sosLoadError => 'Impossible de charger les alertes SOS.';

  @override
  String get sosAckError => 'Impossible d\'acquitter l\'alerte.';

  @override
  String get permissionLocationTitle => 'Localisation requise';

  @override
  String get permissionLocationBody =>
      'KimiaCare a besoin de votre position pour surveiller les zones';

  @override
  String get permissionLocationGrant => 'Autoriser';

  @override
  String get agendaNoEvents => 'Aucun événement';

  @override
  String get agendaTasksShortcut => 'Mes tâches';

  @override
  String get agendaGoogleShortcut => 'Google Calendar';

  @override
  String get agendaEventDetailTitle => 'Détails';

  @override
  String get agendaEventEdit => 'Modifier';

  @override
  String get agendaEventImportant => 'Marquer important';

  @override
  String get agendaEventDelete => 'Supprimer';

  @override
  String get agendaEventDeleteConfirm => 'Supprimer cet événement ?';

  @override
  String get agendaEventDeleteConfirmYes => 'Supprimer';

  @override
  String get agendaEventDeleteConfirmNo => 'Annuler';

  @override
  String get agendaEventLocation => 'Lieu';

  @override
  String get agendaEventReminder => 'Rappel';

  @override
  String agendaEventReminderMinutes(int n) {
    return '$n min avant';
  }

  @override
  String get agendaEventRecurrence => 'Récurrence';

  @override
  String get agendaEditorNewTitle => 'Nouvel événement';

  @override
  String get agendaEditorEditTitle => 'Modifier l\'événement';

  @override
  String get agendaEditorSave => 'Enregistrer';

  @override
  String get agendaEditorFieldTitle => 'Titre';

  @override
  String get agendaEditorFieldDescription => 'Description (optionnel)';

  @override
  String get agendaEditorFieldLocation => 'Lieu (optionnel)';

  @override
  String get agendaEditorFieldStart => 'Début';

  @override
  String get agendaEditorFieldEnd => 'Fin';

  @override
  String get agendaEditorFieldReminder => 'Rappel';

  @override
  String get agendaEditorFieldCategory => 'Catégorie';

  @override
  String get agendaEditorMarkImportant => 'Marquer comme important';

  @override
  String get agendaEditorValidationTitle => 'Titre requis';

  @override
  String get agendaTasksTitle => 'Mes Tâches';

  @override
  String get agendaTasksQuadrantDoFirst => 'Urgent & Important';

  @override
  String get agendaTasksQuadrantSchedule => 'Important, non urgent';

  @override
  String get agendaTasksQuadrantDelegate => 'Urgent, non important';

  @override
  String get agendaTasksQuadrantDelete => 'Ni urgent, ni important';

  @override
  String get agendaTasksEmpty => 'Aucune tâche';

  @override
  String get agendaTasksAdd => 'Nouvelle tâche';

  @override
  String get agendaGoogleTitle => 'Google Calendar';

  @override
  String get agendaGoogleConnectButton => 'Connecter Google Calendar';

  @override
  String get agendaGoogleConnectedAs => 'Connecté en tant que';

  @override
  String get agendaGoogleDisconnect => 'Déconnecter';

  @override
  String get agendaGoogleSync => 'Synchroniser';

  @override
  String get agendaGoogleSyncing => 'Synchronisation...';

  @override
  String get agendaGoogleLastSync => 'Dernière sync.';

  @override
  String get agendaGoogleNotConnected => 'Non connecté';

  @override
  String get agendaCategorySport => 'Sport';

  @override
  String get agendaCategoryMedical => 'Médical';

  @override
  String get agendaCategoryProfessional => 'Professionnel';

  @override
  String get agendaCategorySchool => 'École';

  @override
  String get agendaCategoryLeisure => 'Loisirs';

  @override
  String get agendaCategoryOther => 'Autre';

  @override
  String get messagesModuleTitle => 'Messages';

  @override
  String get messagesModuleSubtitle => 'WhatsApp · Signal · SMS';

  @override
  String get messagesModuleBadge => 'actif';

  @override
  String get messagesScreenTitle => 'Messages & SMS';

  @override
  String get messagesRefreshTooltip => 'Rafraîchir les messages';

  @override
  String get messagesListenerEnabledTitle => 'Accès aux notifications actif';

  @override
  String get messagesListenerEnabledSubtitle =>
      'WhatsApp, Signal et Telegram sont surveillés';

  @override
  String get messagesListenerDisabledTitle => 'Accès aux notifications requis';

  @override
  String get messagesListenerDisabledSubtitle =>
      'Activez l\'accès pour capturer WhatsApp, Signal et Telegram';

  @override
  String get messagesListenerEnableCta => 'Activer l\'accès';

  @override
  String get messagesSectionRules => 'RÈGLES DE FILTRAGE';

  @override
  String get messagesSectionRecent => 'MESSAGES RÉCENTS';

  @override
  String get messagesStatTotal => 'Reçus';

  @override
  String get messagesStatBlocked => 'Bloqués';

  @override
  String get messagesStatRules => 'Règles';

  @override
  String get messagesEmptyState =>
      'Aucun message capturé.\nActivez l\'accès aux notifications\npuis envoyez un SMS ou un message WhatsApp.';

  @override
  String get messagesIosLimitation =>
      'iOS : WhatsApp et Signal ne peuvent pas être interceptés par KimiaCare en raison du sandboxing Apple. Seuls les SMS sont filtrables via SMS Filter Extension. Utilisez Screen Time pour limiter WhatsApp sur iOS.';

  @override
  String get messagesPermissionRequiredTitle => 'Permission SMS requise';

  @override
  String get messagesPermissionRequiredSubtitle =>
      'Activez l\'accès aux SMS pour les voir dans KimiaCare';

  @override
  String get messagesPermissionAllowCta => 'Autoriser';

  @override
  String get messagesPermissionDeniedSnack =>
      'Permission SMS refusée. Vous pouvez l\'activer dans les paramètres de l\'application.';

  @override
  String get messageBlockedBadge => 'Bloqué';

  @override
  String get messageRuleNewTitle => 'Nouvelle règle';

  @override
  String get messageRuleEditTitle => 'Modifier la règle';

  @override
  String get messageRuleLabelType => 'Type de règle';

  @override
  String get messageRuleLabelContact => 'Numéro ou nom';

  @override
  String get messageRuleLabelKeyword => 'Mot-clé';

  @override
  String get messageRuleHintKeyword => 'spam, pub, promo...';

  @override
  String get messageRulePickContacts => 'Choisir depuis mes contacts';

  @override
  String get messageRuleScheduleInfo =>
      'Plage horaire : la règle s\'applique entre ces heures';

  @override
  String get messageRuleScheduleLabel => 'Plage (ex : 22-7)';

  @override
  String get messageRuleLabelAction => 'Action';

  @override
  String get messageRuleLabelSources => 'Sources';

  @override
  String get messageRuleSourcesAll => 'Laisser vide pour toutes les sources';

  @override
  String get messageRuleValidationEmpty => 'Saisissez une valeur';

  @override
  String get messageRuleAddButton => 'Ajouter la règle';

  @override
  String get messageRuleEditButton => 'Enregistrer';

  @override
  String get messageRuleScheduleDisplay => '(plage horaire)';

  @override
  String get fitnessPermissionTitle => 'Accès à l\'activité requis';

  @override
  String get fitnessPermissionSubtitle =>
      'KimiaCare a besoin de votre permission pour compter vos pas et suivre votre activité';

  @override
  String get fitnessPermissionAllowCta => 'Autoriser l\'accès';

  @override
  String get fitnessGoalTitle => 'OBJECTIF QUOTIDIEN';

  @override
  String fitnessGoalSteps(int count) {
    return '$count pas / jour';
  }

  @override
  String get fitnessStartWorkout => 'Démarrer une séance';

  @override
  String get fitnessStopWorkout => 'Arrêter';

  @override
  String get fitnessWorkoutRunning => 'Séance en cours';

  @override
  String get fitnessActiveMinutes => 'Min. actives';

  @override
  String get fitnessWorkoutTypeWalk => 'Marche';

  @override
  String get fitnessWorkoutTypeRun => 'Course';

  @override
  String get fitnessWorkoutTypeCycle => 'Vélo';

  @override
  String get childSettingsTitle => 'Paramètres de l\'enfant';

  @override
  String get sosContactsTitle => 'Contacts SOS';

  @override
  String get sosContactsEmpty => 'Aucun contact SOS';

  @override
  String get sosContactsAdd => 'Ajouter un contact';

  @override
  String get sosContactsCall => 'Appeler';

  @override
  String get sosContactsSms => 'SMS';

  @override
  String get subscriptionPaywallTitle => 'KimiaCare Premium';

  @override
  String get subscriptionPaywallSubtitle =>
      'Débloquez toutes les fonctionnalités';

  @override
  String get subscriptionCtaStart => 'Commencer maintenant';

  @override
  String get subscriptionRestorePurchases => 'Restaurer les achats';

  @override
  String get subscriptionPeriodMonthly => 'Mensuel';

  @override
  String get subscriptionPeriodYearly => 'Annuel  −20%';

  @override
  String get subscriptionPeriodLifetime => 'une fois';

  @override
  String subscriptionTrialNote(int days) {
    return 'Essai gratuit $days jours — annulation à tout moment';
  }

  @override
  String get subscriptionStatusTitle => 'Mon abonnement';

  @override
  String get subscriptionStatusFree => 'Gratuit';

  @override
  String get subscriptionStatusActive => 'Actif';

  @override
  String get subscriptionStatusTrial => 'Essai gratuit';

  @override
  String get subscriptionStatusExpired => 'Expiré';

  @override
  String get subscriptionUpgradeCta => 'Voir les plans';

  @override
  String get subscriptionManage => 'Gérer l\'abonnement';

  @override
  String get subscriptionManageSubtitle =>
      'Modifier ou annuler via l\'App Store / Google Play';

  @override
  String get subscriptionWillNotRenew =>
      'Votre abonnement ne sera pas renouvelé.';

  @override
  String get subscriptionUpgradeTitle => 'Passer à Premium';

  @override
  String get subscriptionUpgradeSubtitle =>
      'Débloquez la blacklist illimitée, les profils enfants et le suivi fitness avancé.';

  @override
  String get moduleMeditationTitle => 'Méditation';

  @override
  String get moduleMeditationSubtitle => 'Sessions guidées';

  @override
  String get moduleMeditationBadge => 'Nouveau';

  @override
  String get splashTagline => 'Votre sanctuaire numérique';

  @override
  String get splashCtaButton => 'Entrer dans KimiaCare';

  @override
  String get messageDetailTypeSms => 'SMS';

  @override
  String get messageDetailTypeWhatsapp => 'WhatsApp';

  @override
  String get messageDetailTypeSignal => 'Signal';

  @override
  String get messageDetailTypeTelegram => 'Telegram';

  @override
  String get messageDetailMarkRead => 'Marquer comme lu';

  @override
  String get messageDetailBlockContact => 'Bloquer ce contact';

  @override
  String get callFilterRulesTitle => 'Filtrage des appels';

  @override
  String get callFilterRulesSubtitle =>
      'Gérer les numéros autorisés ou bloqués';

  @override
  String get callFilterModeBlacklist => 'Liste noire';

  @override
  String get callFilterModeWhitelist => 'Liste blanche';

  @override
  String get callFilterModeBlacklistDesc =>
      'Tous les appels sont autorisés sauf les numéros listés';

  @override
  String get callFilterModeWhitelistDesc =>
      'Seuls les numéros listés peuvent appeler';

  @override
  String get callFilterRulesEmpty => 'Aucun numéro dans la liste';

  @override
  String get callFilterRulesEmptyDesc =>
      'Ajoutez des numéros à bloquer ou autoriser selon le mode actif';

  @override
  String get callFilterAddRule => 'Ajouter un numéro';

  @override
  String get callFilterPhoneLabel => 'Numéro de téléphone';

  @override
  String get callFilterPhoneHint => '+33 6 12 34 56 78';

  @override
  String get callFilterLabelOptional => 'Étiquette (optionnel)';

  @override
  String get callFilterTypeBlacklist => 'Bloqué';

  @override
  String get callFilterTypeWhitelist => 'Autorisé';

  @override
  String get callFilterDeleteConfirm => 'Supprimer cette règle ?';

  @override
  String get callFilterDeleteContent => 'Ce numéro sera retiré de la liste.';

  @override
  String get callFilterDuplicateError => 'Ce numéro est déjà dans la liste';

  @override
  String get callFilterSaveError => 'Erreur lors de l\'enregistrement';

  @override
  String get callFilterLoadError => 'Erreur de chargement des règles';

  @override
  String get callFilterDeleteError => 'Erreur lors de la suppression';

  @override
  String get callFilterInfoBanner =>
      'Les numéros ajoutés ici sont appliqués automatiquement sur l\'appareil de l\'enfant.';

  @override
  String get callFilterPhoneEmptyError => 'Veuillez saisir un numéro';

  @override
  String get greetingMorning => 'Bonne matinée 🌅';

  @override
  String get greetingAfternoon => 'Bonne après-midi ☀';

  @override
  String get greetingEvening => 'Bonsoir 🌙';

  @override
  String get greetingNight => 'Belle nuit 🌟';

  @override
  String welcomeStatsFiltered(int count) {
    return '$count messages filtrés aujourd\'hui';
  }

  @override
  String welcomeStatsSteps(int current, int goal) {
    return '$current / $goal pas';
  }

  @override
  String welcomeStatsEvents(int count) {
    return '$count événements aujourd\'hui';
  }
}
