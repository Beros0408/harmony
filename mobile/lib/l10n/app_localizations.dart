import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt')
  ];

  /// Nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'Harmony'**
  String get appName;

  /// Titre de la barre d'app dashboard
  ///
  /// In fr, this message translates to:
  /// **'Harmony'**
  String get dashboardTitle;

  /// No description provided for @dashboardWelcomeWave.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue 👋'**
  String get dashboardWelcomeWave;

  /// No description provided for @dashboardAllServicesActive.
  ///
  /// In fr, this message translates to:
  /// **'Tous les services actifs'**
  String get dashboardAllServicesActive;

  /// No description provided for @dashboardSectionModules.
  ///
  /// In fr, this message translates to:
  /// **'MES MODULES'**
  String get dashboardSectionModules;

  /// No description provided for @moduleSecurityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get moduleSecurityTitle;

  /// No description provided for @moduleSecuritySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Filtrage actif'**
  String get moduleSecuritySubtitle;

  /// No description provided for @moduleSecurityBadge.
  ///
  /// In fr, this message translates to:
  /// **'actif'**
  String get moduleSecurityBadge;

  /// No description provided for @moduleFamilyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Famille'**
  String get moduleFamilyTitle;

  /// No description provided for @moduleFamilySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Contrôle parental'**
  String get moduleFamilySubtitle;

  /// No description provided for @moduleFamilyBadgeProfiles.
  ///
  /// In fr, this message translates to:
  /// **'{count} profils'**
  String moduleFamilyBadgeProfiles(int count);

  /// No description provided for @moduleFitnessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fitness'**
  String get moduleFitnessTitle;

  /// No description provided for @moduleFitnessSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{current} / {goal} pas'**
  String moduleFitnessSubtitle(int current, int goal);

  /// No description provided for @moduleFitnessBadge.
  ///
  /// In fr, this message translates to:
  /// **'en cours'**
  String get moduleFitnessBadge;

  /// No description provided for @moduleAgendaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Agenda'**
  String get moduleAgendaTitle;

  /// No description provided for @moduleAgendaSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} événements'**
  String moduleAgendaSubtitle(int count);

  /// No description provided for @moduleAgendaBadge.
  ///
  /// In fr, this message translates to:
  /// **'aujourd\'hui'**
  String get moduleAgendaBadge;

  /// No description provided for @navBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get navBack;

  /// No description provided for @navBackToDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Retour au tableau de bord'**
  String get navBackToDashboard;

  /// No description provided for @securityScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité & Filtrage'**
  String get securityScreenTitle;

  /// No description provided for @securityStatsBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Bloqués'**
  String get securityStatsBlocked;

  /// No description provided for @securityStatsRules.
  ///
  /// In fr, this message translates to:
  /// **'Règles'**
  String get securityStatsRules;

  /// No description provided for @securityStatsPrecision.
  ///
  /// In fr, this message translates to:
  /// **'Précision'**
  String get securityStatsPrecision;

  /// No description provided for @securitySectionActiveMode.
  ///
  /// In fr, this message translates to:
  /// **'MODE ACTIF'**
  String get securitySectionActiveMode;

  /// No description provided for @securityModeNormal.
  ///
  /// In fr, this message translates to:
  /// **'Mode Normal'**
  String get securityModeNormal;

  /// No description provided for @securityModeFocus.
  ///
  /// In fr, this message translates to:
  /// **'Mode Focus'**
  String get securityModeFocus;

  /// No description provided for @securityModeNight.
  ///
  /// In fr, this message translates to:
  /// **'Mode Nuit'**
  String get securityModeNight;

  /// No description provided for @securitySectionRules.
  ///
  /// In fr, this message translates to:
  /// **'RÈGLES DE FILTRAGE'**
  String get securitySectionRules;

  /// No description provided for @securityRuleUnknownNumbers.
  ///
  /// In fr, this message translates to:
  /// **'Numéros inconnus'**
  String get securityRuleUnknownNumbers;

  /// No description provided for @securityRuleUnknownNumbersDesc.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer tous les appels non identifiés'**
  String get securityRuleUnknownNumbersDesc;

  /// No description provided for @securityRuleSpam.
  ///
  /// In fr, this message translates to:
  /// **'Démarchage'**
  String get securityRuleSpam;

  /// No description provided for @securityRuleSpamDesc.
  ///
  /// In fr, this message translates to:
  /// **'Détection IA des appels commerciaux'**
  String get securityRuleSpamDesc;

  /// No description provided for @securityRuleBlacklist.
  ///
  /// In fr, this message translates to:
  /// **'Liste noire personnelle'**
  String get securityRuleBlacklist;

  /// No description provided for @securityRuleBlacklistDesc.
  ///
  /// In fr, this message translates to:
  /// **'{count} numéros'**
  String securityRuleBlacklistDesc(int count);

  /// No description provided for @securityRuleForeign.
  ///
  /// In fr, this message translates to:
  /// **'Numéros étrangers'**
  String get securityRuleForeign;

  /// No description provided for @securityRuleForeignDesc.
  ///
  /// In fr, this message translates to:
  /// **'Indicatifs hors France'**
  String get securityRuleForeignDesc;

  /// No description provided for @securityRuleWhitelist.
  ///
  /// In fr, this message translates to:
  /// **'Whitelist familiale'**
  String get securityRuleWhitelist;

  /// No description provided for @securityRuleWhitelistDesc.
  ///
  /// In fr, this message translates to:
  /// **'{count} contacts toujours autorisés'**
  String securityRuleWhitelistDesc(int count);

  /// No description provided for @securitySectionRecentBlocked.
  ///
  /// In fr, this message translates to:
  /// **'DERNIERS APPELS BLOQUÉS'**
  String get securitySectionRecentBlocked;

  /// No description provided for @securitySeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get securitySeeAll;

  /// No description provided for @familyScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Famille & Contrôle parental'**
  String get familyScreenTitle;

  /// No description provided for @familySectionChildren.
  ///
  /// In fr, this message translates to:
  /// **'MES ENFANTS'**
  String get familySectionChildren;

  /// No description provided for @familyChildAge.
  ///
  /// In fr, this message translates to:
  /// **'{name}, {age} ans'**
  String familyChildAge(String name, int age);

  /// No description provided for @familyStatusAtSchool.
  ///
  /// In fr, this message translates to:
  /// **'À l\'école'**
  String get familyStatusAtSchool;

  /// No description provided for @familyStatusAtHome.
  ///
  /// In fr, this message translates to:
  /// **'À la maison'**
  String get familyStatusAtHome;

  /// No description provided for @familyScoreLabel.
  ///
  /// In fr, this message translates to:
  /// **'Score {value}'**
  String familyScoreLabel(int value);

  /// No description provided for @familyChildDetailsToast.
  ///
  /// In fr, this message translates to:
  /// **'Détails de {name} à venir au Sprint 2'**
  String familyChildDetailsToast(String name);

  /// No description provided for @familySectionLocation.
  ///
  /// In fr, this message translates to:
  /// **'LOCALISATION EN TEMPS RÉEL'**
  String get familySectionLocation;

  /// No description provided for @familyMapPlaceholderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte interactive à venir'**
  String get familyMapPlaceholderTitle;

  /// No description provided for @familyMapPlaceholderSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Google Maps — Sprint 2'**
  String get familyMapPlaceholderSubtitle;

  /// No description provided for @familySectionZones.
  ///
  /// In fr, this message translates to:
  /// **'ZONES AUTORISÉES'**
  String get familySectionZones;

  /// No description provided for @familyZoneHome.
  ///
  /// In fr, this message translates to:
  /// **'Maison'**
  String get familyZoneHome;

  /// No description provided for @familyZoneHomeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rayon 250m · Activée 24h/24'**
  String get familyZoneHomeDesc;

  /// No description provided for @familyZoneSchool.
  ///
  /// In fr, this message translates to:
  /// **'École Jules Ferry'**
  String get familyZoneSchool;

  /// No description provided for @familyZoneSchoolDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rayon 100m · Lun-Ven 8h-17h'**
  String get familyZoneSchoolDesc;

  /// No description provided for @familyZoneStadium.
  ///
  /// In fr, this message translates to:
  /// **'Stade municipal'**
  String get familyZoneStadium;

  /// No description provided for @familyZoneStadiumDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rayon 150m · Mer-Sam après-midi'**
  String get familyZoneStadiumDesc;

  /// No description provided for @familySectionLimits.
  ///
  /// In fr, this message translates to:
  /// **'LIMITES QUOTIDIENNES'**
  String get familySectionLimits;

  /// No description provided for @familyLimitScreen.
  ///
  /// In fr, this message translates to:
  /// **'Temps d\'écran aujourd\'hui'**
  String get familyLimitScreen;

  /// No description provided for @familyLimitDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance de la maison'**
  String get familyLimitDistance;

  /// No description provided for @fitnessScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fitness & Performance'**
  String get fitnessScreenTitle;

  /// No description provided for @fitnessSectionToday.
  ///
  /// In fr, this message translates to:
  /// **'AUJOURD\'HUI'**
  String get fitnessSectionToday;

  /// No description provided for @fitnessSteps.
  ///
  /// In fr, this message translates to:
  /// **'Pas'**
  String get fitnessSteps;

  /// No description provided for @fitnessStepsGoal.
  ///
  /// In fr, this message translates to:
  /// **'/ {goal} obj.'**
  String fitnessStepsGoal(int goal);

  /// No description provided for @fitnessCalories.
  ///
  /// In fr, this message translates to:
  /// **'Calories'**
  String get fitnessCalories;

  /// No description provided for @fitnessCaloriesUnit.
  ///
  /// In fr, this message translates to:
  /// **'kcal'**
  String get fitnessCaloriesUnit;

  /// No description provided for @fitnessDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get fitnessDistance;

  /// No description provided for @fitnessDistanceUnit.
  ///
  /// In fr, this message translates to:
  /// **'km'**
  String get fitnessDistanceUnit;

  /// No description provided for @fitnessHeartRate.
  ///
  /// In fr, this message translates to:
  /// **'BPM moyen'**
  String get fitnessHeartRate;

  /// No description provided for @fitnessHeartRateUnit.
  ///
  /// In fr, this message translates to:
  /// **'bpm'**
  String get fitnessHeartRateUnit;

  /// No description provided for @fitnessSectionWeekly.
  ///
  /// In fr, this message translates to:
  /// **'ACTIVITÉ HEBDOMADAIRE'**
  String get fitnessSectionWeekly;

  /// No description provided for @fitnessWeekdayMon.
  ///
  /// In fr, this message translates to:
  /// **'L'**
  String get fitnessWeekdayMon;

  /// No description provided for @fitnessWeekdayTue.
  ///
  /// In fr, this message translates to:
  /// **'M'**
  String get fitnessWeekdayTue;

  /// No description provided for @fitnessWeekdayWed.
  ///
  /// In fr, this message translates to:
  /// **'M'**
  String get fitnessWeekdayWed;

  /// No description provided for @fitnessWeekdayThu.
  ///
  /// In fr, this message translates to:
  /// **'J'**
  String get fitnessWeekdayThu;

  /// No description provided for @fitnessWeekdayFri.
  ///
  /// In fr, this message translates to:
  /// **'V'**
  String get fitnessWeekdayFri;

  /// No description provided for @fitnessWeekdaySat.
  ///
  /// In fr, this message translates to:
  /// **'S'**
  String get fitnessWeekdaySat;

  /// No description provided for @fitnessWeekdaySun.
  ///
  /// In fr, this message translates to:
  /// **'D'**
  String get fitnessWeekdaySun;

  /// No description provided for @fitnessSectionRecords.
  ///
  /// In fr, this message translates to:
  /// **'MES RECORDS'**
  String get fitnessSectionRecords;

  /// No description provided for @fitnessRecordLongestWalk.
  ///
  /// In fr, this message translates to:
  /// **'Plus longue marche'**
  String get fitnessRecordLongestWalk;

  /// No description provided for @fitnessRecordLongestWalkDesc.
  ///
  /// In fr, this message translates to:
  /// **'12.5 km · il y a 2 semaines'**
  String get fitnessRecordLongestWalkDesc;

  /// No description provided for @fitnessRecordMostSteps.
  ///
  /// In fr, this message translates to:
  /// **'Plus de pas en 1 jour'**
  String get fitnessRecordMostSteps;

  /// No description provided for @fitnessRecordMostStepsDesc.
  ///
  /// In fr, this message translates to:
  /// **'14 832 pas · il y a 1 mois'**
  String get fitnessRecordMostStepsDesc;

  /// No description provided for @fitnessRecordFastestRun.
  ///
  /// In fr, this message translates to:
  /// **'Course la plus rapide'**
  String get fitnessRecordFastestRun;

  /// No description provided for @fitnessRecordFastestRunDesc.
  ///
  /// In fr, this message translates to:
  /// **'5km en 28 min · il y a 3 jours'**
  String get fitnessRecordFastestRunDesc;

  /// No description provided for @fitnessSectionSessions.
  ///
  /// In fr, this message translates to:
  /// **'DERNIÈRES SÉANCES'**
  String get fitnessSectionSessions;

  /// No description provided for @fitnessSessionWalk.
  ///
  /// In fr, this message translates to:
  /// **'Marche'**
  String get fitnessSessionWalk;

  /// No description provided for @fitnessSessionWalkDesc.
  ///
  /// In fr, this message translates to:
  /// **'35min · 3.2km · hier 18h12'**
  String get fitnessSessionWalkDesc;

  /// No description provided for @fitnessSessionRun.
  ///
  /// In fr, this message translates to:
  /// **'Course'**
  String get fitnessSessionRun;

  /// No description provided for @fitnessSessionRunDesc.
  ///
  /// In fr, this message translates to:
  /// **'28min · 5km · il y a 3 jours'**
  String get fitnessSessionRunDesc;

  /// No description provided for @fitnessSessionBike.
  ///
  /// In fr, this message translates to:
  /// **'Vélo'**
  String get fitnessSessionBike;

  /// No description provided for @fitnessSessionBikeDesc.
  ///
  /// In fr, this message translates to:
  /// **'1h12 · 18km · il y a 5 jours'**
  String get fitnessSessionBikeDesc;

  /// No description provided for @agendaScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Agenda & Planification'**
  String get agendaScreenTitle;

  /// No description provided for @agendaDateToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get agendaDateToday;

  /// No description provided for @agendaNavigationToast.
  ///
  /// In fr, this message translates to:
  /// **'Navigation jour à venir'**
  String get agendaNavigationToast;

  /// No description provided for @agendaSectionModes.
  ///
  /// In fr, this message translates to:
  /// **'MODES DU JOUR'**
  String get agendaSectionModes;

  /// No description provided for @agendaModeFocus.
  ///
  /// In fr, this message translates to:
  /// **'Concentration'**
  String get agendaModeFocus;

  /// No description provided for @agendaModeFocusDesc.
  ///
  /// In fr, this message translates to:
  /// **'Notifications limitées'**
  String get agendaModeFocusDesc;

  /// No description provided for @agendaModeSleep.
  ///
  /// In fr, this message translates to:
  /// **'Sommeil'**
  String get agendaModeSleep;

  /// No description provided for @agendaModeSleepDesc.
  ///
  /// In fr, this message translates to:
  /// **'Programmé 22h-7h'**
  String get agendaModeSleepDesc;

  /// No description provided for @agendaSectionEvents.
  ///
  /// In fr, this message translates to:
  /// **'MES ÉVÉNEMENTS DU JOUR'**
  String get agendaSectionEvents;

  /// No description provided for @agendaEventMeeting.
  ///
  /// In fr, this message translates to:
  /// **'Réunion équipe produit'**
  String get agendaEventMeeting;

  /// No description provided for @agendaEventMeetingTime.
  ///
  /// In fr, this message translates to:
  /// **'14h00–15h00 · Bureau'**
  String get agendaEventMeetingTime;

  /// No description provided for @agendaEventMeetingDetail.
  ///
  /// In fr, this message translates to:
  /// **'{count} participants'**
  String agendaEventMeetingDetail(int count);

  /// No description provided for @agendaEventDinner.
  ///
  /// In fr, this message translates to:
  /// **'Dîner avec parents'**
  String get agendaEventDinner;

  /// No description provided for @agendaEventDinnerTime.
  ///
  /// In fr, this message translates to:
  /// **'19h30–21h00 · À la maison'**
  String get agendaEventDinnerTime;

  /// No description provided for @agendaEventDinnerDetail.
  ///
  /// In fr, this message translates to:
  /// **'Maison'**
  String get agendaEventDinnerDetail;

  /// No description provided for @agendaEventYoga.
  ///
  /// In fr, this message translates to:
  /// **'Cours de yoga'**
  String get agendaEventYoga;

  /// No description provided for @agendaEventYogaTime.
  ///
  /// In fr, this message translates to:
  /// **'18h00–19h00'**
  String get agendaEventYogaTime;

  /// No description provided for @agendaEventYogaDetail.
  ///
  /// In fr, this message translates to:
  /// **'Studio Mahalo'**
  String get agendaEventYogaDetail;

  /// No description provided for @agendaCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel événement'**
  String get agendaCreateButton;

  /// No description provided for @agendaCreateToast.
  ///
  /// In fr, this message translates to:
  /// **'Création d\'événement à venir au Sprint 4'**
  String get agendaCreateToast;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Harmony'**
  String get authWelcomeTitle;

  /// No description provided for @authCreatePinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer votre code PIN'**
  String get authCreatePinTitle;

  /// No description provided for @authChoosePin.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un code à 4 chiffres'**
  String get authChoosePin;

  /// No description provided for @authConfirmPinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre code PIN'**
  String get authConfirmPinTitle;

  /// No description provided for @authReenterPin.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez à nouveau le code PIN'**
  String get authReenterPin;

  /// No description provided for @authEnterPin.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre code PIN'**
  String get authEnterPin;

  /// No description provided for @authPinMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les codes ne correspondent pas'**
  String get authPinMismatch;

  /// No description provided for @authIncorrectCode.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect'**
  String get authIncorrectCode;

  /// No description provided for @authAttemptsLeft.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 essai restant} other{{count} essais restants}}'**
  String authAttemptsLeft(int count);

  /// No description provided for @authBiometricSetupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer la biométrie ?'**
  String get authBiometricSetupTitle;

  /// No description provided for @authBiometricSetupDesc.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouillez Harmony avec Face ID ou votre empreinte digitale.'**
  String get authBiometricSetupDesc;

  /// No description provided for @authBiometricEnable.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get authBiometricEnable;

  /// No description provided for @authBiometricLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get authBiometricLater;

  /// No description provided for @authBiometricSkip.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer'**
  String get authBiometricSkip;

  /// No description provided for @emptyStateComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get emptyStateComingSoon;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In fr, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguagePortuguese.
  ///
  /// In fr, this message translates to:
  /// **'Português'**
  String get settingsLanguagePortuguese;

  /// No description provided for @settingsLanguageItalian.
  ///
  /// In fr, this message translates to:
  /// **'Italiano'**
  String get settingsLanguageItalian;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get settingsThemeDark;

  /// No description provided for @moduleContactsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get moduleContactsTitle;

  /// No description provided for @moduleContactsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des contacts'**
  String get moduleContactsSubtitle;

  /// No description provided for @moduleContactsBadge.
  ///
  /// In fr, this message translates to:
  /// **'{count} contacts'**
  String moduleContactsBadge(int count);

  /// No description provided for @contactsScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get contactsScreenTitle;

  /// No description provided for @contactsSectionWhitelist.
  ///
  /// In fr, this message translates to:
  /// **'LISTE BLANCHE'**
  String get contactsSectionWhitelist;

  /// No description provided for @contactsSectionBlacklist.
  ///
  /// In fr, this message translates to:
  /// **'LISTE NOIRE'**
  String get contactsSectionBlacklist;

  /// No description provided for @contactsAddContact.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un contact'**
  String get contactsAddContact;

  /// No description provided for @contactsWhitelistBadge.
  ///
  /// In fr, this message translates to:
  /// **'autorisé'**
  String get contactsWhitelistBadge;

  /// No description provided for @contactsBlacklistBadge.
  ///
  /// In fr, this message translates to:
  /// **'bloqué'**
  String get contactsBlacklistBadge;

  /// No description provided for @contactsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact'**
  String get contactsEmpty;

  /// No description provided for @contactsRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get contactsRemove;

  /// No description provided for @voicemailScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Messagerie vocale'**
  String get voicemailScreenTitle;

  /// No description provided for @voicemailNewCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun nouveau message} =1{1 nouveau message} other{{count} nouveaux messages}}'**
  String voicemailNewCount(int count);

  /// No description provided for @voicemailTotal.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 message au total} other{{count} messages au total}}'**
  String voicemailTotal(int count);

  /// No description provided for @voicemailPushInfo.
  ///
  /// In fr, this message translates to:
  /// **'Simulation de push activée'**
  String get voicemailPushInfo;

  /// No description provided for @voicemailMarkRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme lu'**
  String get voicemailMarkRead;

  /// No description provided for @voicemailDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get voicemailDelete;

  /// No description provided for @voicemailCallBack.
  ///
  /// In fr, this message translates to:
  /// **'Rappeler'**
  String get voicemailCallBack;

  /// No description provided for @voicemailUrgent.
  ///
  /// In fr, this message translates to:
  /// **'Urgent'**
  String get voicemailUrgent;

  /// No description provided for @voicemailNewMessageToastTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message vocal'**
  String get voicemailNewMessageToastTitle;

  /// No description provided for @voicemailNewMessageToastBody.
  ///
  /// In fr, this message translates to:
  /// **'Message de {name}'**
  String voicemailNewMessageToastBody(String name);

  /// No description provided for @voicemailViewButton.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get voicemailViewButton;

  /// No description provided for @voicemailTranscriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Transcription'**
  String get voicemailTranscriptionLabel;

  /// No description provided for @voicemailExpandHint.
  ///
  /// In fr, this message translates to:
  /// **'Voir la transcription'**
  String get voicemailExpandHint;

  /// No description provided for @voicemailMockNote.
  ///
  /// In fr, this message translates to:
  /// **'Transcriptions simulées — vraie STT au Sprint 5'**
  String get voicemailMockNote;

  /// No description provided for @voicemailPlay.
  ///
  /// In fr, this message translates to:
  /// **'Écouter'**
  String get voicemailPlay;

  /// No description provided for @callScreeningEnableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer la protection'**
  String get callScreeningEnableTitle;

  /// No description provided for @callScreeningEnableDescription.
  ///
  /// In fr, this message translates to:
  /// **'Pour bloquer les appels indésirables, Harmony doit être votre application de filtrage par défaut'**
  String get callScreeningEnableDescription;

  /// No description provided for @callScreeningEnableButton.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get callScreeningEnableButton;

  /// No description provided for @callScreeningActiveStatus.
  ///
  /// In fr, this message translates to:
  /// **'Protection active'**
  String get callScreeningActiveStatus;

  /// No description provided for @callLogScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journal des blocages'**
  String get callLogScreenTitle;

  /// No description provided for @callLogFilterToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get callLogFilterToday;

  /// No description provided for @callLogFilterWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get callLogFilterWeek;

  /// No description provided for @callLogFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get callLogFilterAll;

  /// No description provided for @callLogEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appel bloqué'**
  String get callLogEmptyState;

  /// No description provided for @callLogClearAllButton.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get callLogClearAllButton;

  /// No description provided for @iosFilteringTitle.
  ///
  /// In fr, this message translates to:
  /// **'Filtrage iOS'**
  String get iosFilteringTitle;

  /// No description provided for @iosFilteringInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Pour activer le blocage d\'appels sur iOS, activez l\'extension dans Réglages.'**
  String get iosFilteringInstructions;

  /// No description provided for @iosFilteringStep1.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez Réglages → Téléphone → Blocage et identification d\'appels'**
  String get iosFilteringStep1;

  /// No description provided for @iosFilteringStep2.
  ///
  /// In fr, this message translates to:
  /// **'Activez Harmony dans la liste'**
  String get iosFilteringStep2;

  /// No description provided for @iosFilteringOpenSettingsButton.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les réglages'**
  String get iosFilteringOpenSettingsButton;

  /// No description provided for @outgoingCallAlertTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appel potentiellement surtaxé'**
  String get outgoingCallAlertTitle;

  /// No description provided for @outgoingCallAlertEstimatedCost.
  ///
  /// In fr, this message translates to:
  /// **'Coût estimé : {cost} €/min'**
  String outgoingCallAlertEstimatedCost(String cost);

  /// No description provided for @outgoingCallAlertCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get outgoingCallAlertCancel;

  /// No description provided for @outgoingCallAlertContinueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer l\'appel'**
  String get outgoingCallAlertContinueButton;

  /// No description provided for @outgoingCallAlertDontAskAgain.
  ///
  /// In fr, this message translates to:
  /// **'Ne plus demander pour ce numéro'**
  String get outgoingCallAlertDontAskAgain;

  /// No description provided for @filterModeOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get filterModeOff;

  /// No description provided for @filterModeNight.
  ///
  /// In fr, this message translates to:
  /// **'Nuit'**
  String get filterModeNight;

  /// No description provided for @filterModeWork.
  ///
  /// In fr, this message translates to:
  /// **'Travail'**
  String get filterModeWork;

  /// No description provided for @filterModeFocus.
  ///
  /// In fr, this message translates to:
  /// **'Focus'**
  String get filterModeFocus;

  /// No description provided for @filterModeWeekend.
  ///
  /// In fr, this message translates to:
  /// **'Week-end'**
  String get filterModeWeekend;

  /// No description provided for @filterModeEmergency.
  ///
  /// In fr, this message translates to:
  /// **'Urgence'**
  String get filterModeEmergency;

  /// No description provided for @filterModeActivate.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get filterModeActivate;

  /// No description provided for @filterModeConfigure.
  ///
  /// In fr, this message translates to:
  /// **'Configurer'**
  String get filterModeConfigure;

  /// No description provided for @filterModeCurrentActive.
  ///
  /// In fr, this message translates to:
  /// **'Mode actif'**
  String get filterModeCurrentActive;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
