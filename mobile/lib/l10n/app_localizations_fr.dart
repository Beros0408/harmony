// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Harmony';

  @override
  String get dashboardTitle => 'Harmony';

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
  String get authWelcomeTitle => 'Bienvenue sur Harmony';

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
      'Déverrouillez Harmony avec Face ID ou votre empreinte digitale.';

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
      'Pour bloquer les appels indésirables, Harmony doit être votre application de filtrage par défaut';

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
  String get iosFilteringStep2 => 'Activez Harmony dans la liste';

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
}
