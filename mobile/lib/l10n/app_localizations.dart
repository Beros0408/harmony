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
  /// **'KimiaCare'**
  String get appName;

  /// Titre de la barre d'app dashboard
  ///
  /// In fr, this message translates to:
  /// **'KimiaCare'**
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
  /// **'Bienvenue sur KimiaCare'**
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
  /// **'Déverrouillez KimiaCare avec Face ID ou votre empreinte digitale.'**
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

  /// No description provided for @contactsPermissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès aux contacts requis'**
  String get contactsPermissionTitle;

  /// No description provided for @contactsPermissionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'KimiaCare a besoin de votre permission pour afficher votre carnet d\'adresses.'**
  String get contactsPermissionSubtitle;

  /// No description provided for @contactsPermissionCta.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser l\'accès aux contacts'**
  String get contactsPermissionCta;

  /// No description provided for @blacklistPickFromContacts.
  ///
  /// In fr, this message translates to:
  /// **'Choisir depuis mes contacts'**
  String get blacklistPickFromContacts;

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
  /// **'Pour bloquer les appels indésirables, KimiaCare doit être votre application de filtrage par défaut'**
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
  /// **'Activez KimiaCare dans la liste'**
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

  /// No description provided for @blacklistScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Liste noire'**
  String get blacklistScreenTitle;

  /// No description provided for @blacklistSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un numéro ou une étiquette...'**
  String get blacklistSearchHint;

  /// No description provided for @blacklistEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun numéro bloqué'**
  String get blacklistEmptyTitle;

  /// No description provided for @blacklistAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un numéro'**
  String get blacklistAddTitle;

  /// No description provided for @blacklistEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'entrée'**
  String get blacklistEditTitle;

  /// No description provided for @blacklistPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get blacklistPhoneLabel;

  /// No description provided for @blacklistPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'+33 6 12 34 56 78'**
  String get blacklistPhoneHint;

  /// No description provided for @blacklistLabelHint.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette (optionnel)'**
  String get blacklistLabelHint;

  /// No description provided for @blacklistReasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Raison du blocage'**
  String get blacklistReasonLabel;

  /// No description provided for @blacklistSaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get blacklistSaveButton;

  /// No description provided for @blacklistReasonSpam.
  ///
  /// In fr, this message translates to:
  /// **'Spam'**
  String get blacklistReasonSpam;

  /// No description provided for @blacklistReasonTelemarketing.
  ///
  /// In fr, this message translates to:
  /// **'Démarchage'**
  String get blacklistReasonTelemarketing;

  /// No description provided for @blacklistReasonHarassment.
  ///
  /// In fr, this message translates to:
  /// **'Harcèlement'**
  String get blacklistReasonHarassment;

  /// No description provided for @blacklistReasonOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get blacklistReasonOther;

  /// No description provided for @familyChildrenSection.
  ///
  /// In fr, this message translates to:
  /// **'MES ENFANTS'**
  String get familyChildrenSection;

  /// No description provided for @familyMapSection.
  ///
  /// In fr, this message translates to:
  /// **'LOCALISATION EN TEMPS RÉEL'**
  String get familyMapSection;

  /// No description provided for @familyZonesSection.
  ///
  /// In fr, this message translates to:
  /// **'ZONES AUTORISÉES'**
  String get familyZonesSection;

  /// No description provided for @familyAddZoneFAB.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une zone'**
  String get familyAddZoneFAB;

  /// No description provided for @childDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail de l\'enfant'**
  String get childDetailTitle;

  /// No description provided for @childAtZone.
  ///
  /// In fr, this message translates to:
  /// **'Dans : {name}'**
  String childAtZone(String name);

  /// No description provided for @childInTransit.
  ///
  /// In fr, this message translates to:
  /// **'En déplacement'**
  String get childInTransit;

  /// No description provided for @childSecurityScore.
  ///
  /// In fr, this message translates to:
  /// **'Score {value}'**
  String childSecurityScore(int value);

  /// No description provided for @zoneEditorAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle zone'**
  String get zoneEditorAddTitle;

  /// No description provided for @zoneEditorEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la zone'**
  String get zoneEditorEditTitle;

  /// No description provided for @zoneFieldName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la zone'**
  String get zoneFieldName;

  /// No description provided for @zoneFieldRadius.
  ///
  /// In fr, this message translates to:
  /// **'Rayon'**
  String get zoneFieldRadius;

  /// No description provided for @zoneFieldIcon.
  ///
  /// In fr, this message translates to:
  /// **'Icône'**
  String get zoneFieldIcon;

  /// No description provided for @zoneIconHome.
  ///
  /// In fr, this message translates to:
  /// **'Maison'**
  String get zoneIconHome;

  /// No description provided for @zoneIconSchool.
  ///
  /// In fr, this message translates to:
  /// **'École'**
  String get zoneIconSchool;

  /// No description provided for @zoneIconSport.
  ///
  /// In fr, this message translates to:
  /// **'Sport'**
  String get zoneIconSport;

  /// No description provided for @zoneIconOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get zoneIconOther;

  /// No description provided for @zoneMapTapHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur la carte pour positionner la zone'**
  String get zoneMapTapHint;

  /// No description provided for @zoneFieldNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : École Jules Ferry'**
  String get zoneFieldNameHint;

  /// No description provided for @zoneChildrenLabel.
  ///
  /// In fr, this message translates to:
  /// **'Enfants concernés'**
  String get zoneChildrenLabel;

  /// No description provided for @familyNoChildrenPaired.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enfant appairé pour le moment'**
  String get familyNoChildrenPaired;

  /// No description provided for @familyAddChildButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un enfant'**
  String get familyAddChildButton;

  /// No description provided for @zoneScheduleAllDay.
  ///
  /// In fr, this message translates to:
  /// **'24h/24'**
  String get zoneScheduleAllDay;

  /// No description provided for @unlinkDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demande de déliage'**
  String get unlinkDialogTitle;

  /// No description provided for @unlinkDialogBody.
  ///
  /// In fr, this message translates to:
  /// **'{childName} demande à retirer cet appareil du contrôle parental. Acceptes-tu ?'**
  String unlinkDialogBody(String childName);

  /// No description provided for @unlinkDialogReject.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get unlinkDialogReject;

  /// No description provided for @unlinkDialogApprove.
  ///
  /// In fr, this message translates to:
  /// **'Approuver'**
  String get unlinkDialogApprove;

  /// No description provided for @unlinkApprovedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Déliage de {childName} approuvé.'**
  String unlinkApprovedSnack(String childName);

  /// No description provided for @unlinkApproveError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'approbation. Réessaie.'**
  String get unlinkApproveError;

  /// No description provided for @unlinkRejectedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Demande de {childName} refusée.'**
  String unlinkRejectedSnack(String childName);

  /// No description provided for @unlinkRejectError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du refus. Réessaie.'**
  String get unlinkRejectError;

  /// No description provided for @sosButtonLabel.
  ///
  /// In fr, this message translates to:
  /// **'SOS'**
  String get sosButtonLabel;

  /// No description provided for @sosHoldHint.
  ///
  /// In fr, this message translates to:
  /// **'Maintenez 3 secondes pour déclencher'**
  String get sosHoldHint;

  /// No description provided for @sosActiveTitle.
  ///
  /// In fr, this message translates to:
  /// **'SOS ACTIF'**
  String get sosActiveTitle;

  /// No description provided for @sosActiveCountdown.
  ///
  /// In fr, this message translates to:
  /// **'Appel dans'**
  String get sosActiveCountdown;

  /// No description provided for @sosActiveCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler le SOS'**
  String get sosActiveCancel;

  /// No description provided for @sosCancelConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous en sécurité ?'**
  String get sosCancelConfirm;

  /// No description provided for @sosTriggerConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une alerte SOS ?'**
  String get sosTriggerConfirmTitle;

  /// No description provided for @sosTriggerConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ton parent sera alerté immédiatement avec ta position.'**
  String get sosTriggerConfirmMessage;

  /// No description provided for @sosTriggerConfirmCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get sosTriggerConfirmCancel;

  /// No description provided for @sosTriggerConfirmSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le SOS'**
  String get sosTriggerConfirmSend;

  /// No description provided for @sosSentSuccess.
  ///
  /// In fr, this message translates to:
  /// **'SOS envoyé, ton parent a été alerté'**
  String get sosSentSuccess;

  /// No description provided for @sosSentError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'envoyer le SOS, vérifie ta connexion'**
  String get sosSentError;

  /// No description provided for @sosSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'ALERTES SOS'**
  String get sosSectionTitle;

  /// No description provided for @sosNoActive.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte SOS — tout va bien.'**
  String get sosNoActive;

  /// No description provided for @sosAcknowledge.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai vu — Acquitter'**
  String get sosAcknowledge;

  /// No description provided for @sosPosition.
  ///
  /// In fr, this message translates to:
  /// **'Position : {lat}, {lon}'**
  String sosPosition(String lat, String lon);

  /// No description provided for @sosViewOnMap.
  ///
  /// In fr, this message translates to:
  /// **'Voir sur la carte'**
  String get sosViewOnMap;

  /// No description provided for @sosLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les alertes SOS.'**
  String get sosLoadError;

  /// No description provided for @sosAckError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'acquitter l\'alerte.'**
  String get sosAckError;

  /// No description provided for @permissionLocationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Localisation requise'**
  String get permissionLocationTitle;

  /// No description provided for @permissionLocationBody.
  ///
  /// In fr, this message translates to:
  /// **'KimiaCare a besoin de votre position pour surveiller les zones'**
  String get permissionLocationBody;

  /// No description provided for @permissionLocationGrant.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get permissionLocationGrant;

  /// No description provided for @agendaNoEvents.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement'**
  String get agendaNoEvents;

  /// No description provided for @agendaTasksShortcut.
  ///
  /// In fr, this message translates to:
  /// **'Mes tâches'**
  String get agendaTasksShortcut;

  /// No description provided for @agendaGoogleShortcut.
  ///
  /// In fr, this message translates to:
  /// **'Google Calendar'**
  String get agendaGoogleShortcut;

  /// No description provided for @agendaEventDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détails'**
  String get agendaEventDetailTitle;

  /// No description provided for @agendaEventEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get agendaEventEdit;

  /// No description provided for @agendaEventImportant.
  ///
  /// In fr, this message translates to:
  /// **'Marquer important'**
  String get agendaEventImportant;

  /// No description provided for @agendaEventDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get agendaEventDelete;

  /// No description provided for @agendaEventDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cet événement ?'**
  String get agendaEventDeleteConfirm;

  /// No description provided for @agendaEventDeleteConfirmYes.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get agendaEventDeleteConfirmYes;

  /// No description provided for @agendaEventDeleteConfirmNo.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get agendaEventDeleteConfirmNo;

  /// No description provided for @agendaEventLocation.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get agendaEventLocation;

  /// No description provided for @agendaEventReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel'**
  String get agendaEventReminder;

  /// No description provided for @agendaEventReminderMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{n} min avant'**
  String agendaEventReminderMinutes(int n);

  /// No description provided for @agendaEventRecurrence.
  ///
  /// In fr, this message translates to:
  /// **'Récurrence'**
  String get agendaEventRecurrence;

  /// No description provided for @agendaEditorNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel événement'**
  String get agendaEditorNewTitle;

  /// No description provided for @agendaEditorEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'événement'**
  String get agendaEditorEditTitle;

  /// No description provided for @agendaEditorSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get agendaEditorSave;

  /// No description provided for @agendaEditorFieldTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get agendaEditorFieldTitle;

  /// No description provided for @agendaEditorFieldDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnel)'**
  String get agendaEditorFieldDescription;

  /// No description provided for @agendaEditorFieldLocation.
  ///
  /// In fr, this message translates to:
  /// **'Lieu (optionnel)'**
  String get agendaEditorFieldLocation;

  /// No description provided for @agendaEditorFieldStart.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get agendaEditorFieldStart;

  /// No description provided for @agendaEditorFieldEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get agendaEditorFieldEnd;

  /// No description provided for @agendaEditorFieldReminder.
  ///
  /// In fr, this message translates to:
  /// **'Rappel'**
  String get agendaEditorFieldReminder;

  /// No description provided for @agendaEditorFieldCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get agendaEditorFieldCategory;

  /// No description provided for @agendaEditorMarkImportant.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme important'**
  String get agendaEditorMarkImportant;

  /// No description provided for @agendaEditorValidationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre requis'**
  String get agendaEditorValidationTitle;

  /// No description provided for @agendaTasksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes Tâches'**
  String get agendaTasksTitle;

  /// No description provided for @agendaTasksQuadrantDoFirst.
  ///
  /// In fr, this message translates to:
  /// **'Urgent & Important'**
  String get agendaTasksQuadrantDoFirst;

  /// No description provided for @agendaTasksQuadrantSchedule.
  ///
  /// In fr, this message translates to:
  /// **'Important, non urgent'**
  String get agendaTasksQuadrantSchedule;

  /// No description provided for @agendaTasksQuadrantDelegate.
  ///
  /// In fr, this message translates to:
  /// **'Urgent, non important'**
  String get agendaTasksQuadrantDelegate;

  /// No description provided for @agendaTasksQuadrantDelete.
  ///
  /// In fr, this message translates to:
  /// **'Ni urgent, ni important'**
  String get agendaTasksQuadrantDelete;

  /// No description provided for @agendaTasksEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche'**
  String get agendaTasksEmpty;

  /// No description provided for @agendaTasksAdd.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle tâche'**
  String get agendaTasksAdd;

  /// No description provided for @agendaGoogleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Google Calendar'**
  String get agendaGoogleTitle;

  /// No description provided for @agendaGoogleConnectButton.
  ///
  /// In fr, this message translates to:
  /// **'Connecter Google Calendar'**
  String get agendaGoogleConnectButton;

  /// No description provided for @agendaGoogleConnectedAs.
  ///
  /// In fr, this message translates to:
  /// **'Connecté en tant que'**
  String get agendaGoogleConnectedAs;

  /// No description provided for @agendaGoogleDisconnect.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter'**
  String get agendaGoogleDisconnect;

  /// No description provided for @agendaGoogleSync.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get agendaGoogleSync;

  /// No description provided for @agendaGoogleSyncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation...'**
  String get agendaGoogleSyncing;

  /// No description provided for @agendaGoogleLastSync.
  ///
  /// In fr, this message translates to:
  /// **'Dernière sync.'**
  String get agendaGoogleLastSync;

  /// No description provided for @agendaGoogleNotConnected.
  ///
  /// In fr, this message translates to:
  /// **'Non connecté'**
  String get agendaGoogleNotConnected;

  /// No description provided for @agendaCategorySport.
  ///
  /// In fr, this message translates to:
  /// **'Sport'**
  String get agendaCategorySport;

  /// No description provided for @agendaCategoryMedical.
  ///
  /// In fr, this message translates to:
  /// **'Médical'**
  String get agendaCategoryMedical;

  /// No description provided for @agendaCategoryProfessional.
  ///
  /// In fr, this message translates to:
  /// **'Professionnel'**
  String get agendaCategoryProfessional;

  /// No description provided for @agendaCategorySchool.
  ///
  /// In fr, this message translates to:
  /// **'École'**
  String get agendaCategorySchool;

  /// No description provided for @agendaCategoryLeisure.
  ///
  /// In fr, this message translates to:
  /// **'Loisirs'**
  String get agendaCategoryLeisure;

  /// No description provided for @agendaCategoryOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get agendaCategoryOther;

  /// No description provided for @messagesModuleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get messagesModuleTitle;

  /// No description provided for @messagesModuleSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp · Signal · SMS'**
  String get messagesModuleSubtitle;

  /// No description provided for @messagesModuleBadge.
  ///
  /// In fr, this message translates to:
  /// **'actif'**
  String get messagesModuleBadge;

  /// No description provided for @messagesScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Messages & SMS'**
  String get messagesScreenTitle;

  /// No description provided for @messagesRefreshTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir les messages'**
  String get messagesRefreshTooltip;

  /// No description provided for @messagesListenerEnabledTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès aux notifications actif'**
  String get messagesListenerEnabledTitle;

  /// No description provided for @messagesListenerEnabledSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp, Signal et Telegram sont surveillés'**
  String get messagesListenerEnabledSubtitle;

  /// No description provided for @messagesListenerDisabledTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès aux notifications requis'**
  String get messagesListenerDisabledTitle;

  /// No description provided for @messagesListenerDisabledSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Activez l\'accès pour capturer WhatsApp, Signal et Telegram'**
  String get messagesListenerDisabledSubtitle;

  /// No description provided for @messagesListenerEnableCta.
  ///
  /// In fr, this message translates to:
  /// **'Activer l\'accès'**
  String get messagesListenerEnableCta;

  /// No description provided for @messagesSectionRules.
  ///
  /// In fr, this message translates to:
  /// **'RÈGLES DE FILTRAGE'**
  String get messagesSectionRules;

  /// No description provided for @messagesSectionRecent.
  ///
  /// In fr, this message translates to:
  /// **'MESSAGES RÉCENTS'**
  String get messagesSectionRecent;

  /// No description provided for @messagesStatTotal.
  ///
  /// In fr, this message translates to:
  /// **'Reçus'**
  String get messagesStatTotal;

  /// No description provided for @messagesStatBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Bloqués'**
  String get messagesStatBlocked;

  /// No description provided for @messagesStatRules.
  ///
  /// In fr, this message translates to:
  /// **'Règles'**
  String get messagesStatRules;

  /// No description provided for @messagesEmptyState.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message capturé.\nActivez l\'accès aux notifications\npuis envoyez un SMS ou un message WhatsApp.'**
  String get messagesEmptyState;

  /// No description provided for @messagesIosLimitation.
  ///
  /// In fr, this message translates to:
  /// **'iOS : WhatsApp et Signal ne peuvent pas être interceptés par KimiaCare en raison du sandboxing Apple. Seuls les SMS sont filtrables via SMS Filter Extension. Utilisez Screen Time pour limiter WhatsApp sur iOS.'**
  String get messagesIosLimitation;

  /// No description provided for @messagesPermissionRequiredTitle.
  ///
  /// In fr, this message translates to:
  /// **'Permission SMS requise'**
  String get messagesPermissionRequiredTitle;

  /// No description provided for @messagesPermissionRequiredSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Activez l\'accès aux SMS pour les voir dans KimiaCare'**
  String get messagesPermissionRequiredSubtitle;

  /// No description provided for @messagesPermissionAllowCta.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser'**
  String get messagesPermissionAllowCta;

  /// No description provided for @messagesPermissionDeniedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Permission SMS refusée. Vous pouvez l\'activer dans les paramètres de l\'application.'**
  String get messagesPermissionDeniedSnack;

  /// No description provided for @messageBlockedBadge.
  ///
  /// In fr, this message translates to:
  /// **'Bloqué'**
  String get messageBlockedBadge;

  /// No description provided for @messageRuleNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle règle'**
  String get messageRuleNewTitle;

  /// No description provided for @messageRuleEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la règle'**
  String get messageRuleEditTitle;

  /// No description provided for @messageRuleLabelType.
  ///
  /// In fr, this message translates to:
  /// **'Type de règle'**
  String get messageRuleLabelType;

  /// No description provided for @messageRuleLabelContact.
  ///
  /// In fr, this message translates to:
  /// **'Numéro ou nom'**
  String get messageRuleLabelContact;

  /// No description provided for @messageRuleLabelKeyword.
  ///
  /// In fr, this message translates to:
  /// **'Mot-clé'**
  String get messageRuleLabelKeyword;

  /// No description provided for @messageRuleHintKeyword.
  ///
  /// In fr, this message translates to:
  /// **'spam, pub, promo...'**
  String get messageRuleHintKeyword;

  /// No description provided for @messageRulePickContacts.
  ///
  /// In fr, this message translates to:
  /// **'Choisir depuis mes contacts'**
  String get messageRulePickContacts;

  /// No description provided for @messageRuleScheduleInfo.
  ///
  /// In fr, this message translates to:
  /// **'Plage horaire : la règle s\'applique entre ces heures'**
  String get messageRuleScheduleInfo;

  /// No description provided for @messageRuleScheduleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Plage (ex : 22-7)'**
  String get messageRuleScheduleLabel;

  /// No description provided for @messageRuleLabelAction.
  ///
  /// In fr, this message translates to:
  /// **'Action'**
  String get messageRuleLabelAction;

  /// No description provided for @messageRuleLabelSources.
  ///
  /// In fr, this message translates to:
  /// **'Sources'**
  String get messageRuleLabelSources;

  /// No description provided for @messageRuleSourcesAll.
  ///
  /// In fr, this message translates to:
  /// **'Laisser vide pour toutes les sources'**
  String get messageRuleSourcesAll;

  /// No description provided for @messageRuleValidationEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez une valeur'**
  String get messageRuleValidationEmpty;

  /// No description provided for @messageRuleAddButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la règle'**
  String get messageRuleAddButton;

  /// No description provided for @messageRuleEditButton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get messageRuleEditButton;

  /// No description provided for @messageRuleScheduleDisplay.
  ///
  /// In fr, this message translates to:
  /// **'(plage horaire)'**
  String get messageRuleScheduleDisplay;

  /// No description provided for @fitnessPermissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès à l\'activité requis'**
  String get fitnessPermissionTitle;

  /// No description provided for @fitnessPermissionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'KimiaCare a besoin de votre permission pour compter vos pas et suivre votre activité'**
  String get fitnessPermissionSubtitle;

  /// No description provided for @fitnessPermissionAllowCta.
  ///
  /// In fr, this message translates to:
  /// **'Autoriser l\'accès'**
  String get fitnessPermissionAllowCta;

  /// No description provided for @fitnessGoalTitle.
  ///
  /// In fr, this message translates to:
  /// **'OBJECTIF QUOTIDIEN'**
  String get fitnessGoalTitle;

  /// No description provided for @fitnessGoalSteps.
  ///
  /// In fr, this message translates to:
  /// **'{count} pas / jour'**
  String fitnessGoalSteps(int count);

  /// No description provided for @fitnessStartWorkout.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer une séance'**
  String get fitnessStartWorkout;

  /// No description provided for @fitnessStopWorkout.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get fitnessStopWorkout;

  /// No description provided for @fitnessWorkoutRunning.
  ///
  /// In fr, this message translates to:
  /// **'Séance en cours'**
  String get fitnessWorkoutRunning;

  /// No description provided for @fitnessActiveMinutes.
  ///
  /// In fr, this message translates to:
  /// **'Min. actives'**
  String get fitnessActiveMinutes;

  /// No description provided for @fitnessWorkoutTypeWalk.
  ///
  /// In fr, this message translates to:
  /// **'Marche'**
  String get fitnessWorkoutTypeWalk;

  /// No description provided for @fitnessWorkoutTypeRun.
  ///
  /// In fr, this message translates to:
  /// **'Course'**
  String get fitnessWorkoutTypeRun;

  /// No description provided for @fitnessWorkoutTypeCycle.
  ///
  /// In fr, this message translates to:
  /// **'Vélo'**
  String get fitnessWorkoutTypeCycle;

  /// No description provided for @childSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de l\'enfant'**
  String get childSettingsTitle;

  /// No description provided for @sosContactsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacts SOS'**
  String get sosContactsTitle;

  /// No description provided for @sosContactsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact SOS'**
  String get sosContactsEmpty;

  /// No description provided for @sosContactsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un contact'**
  String get sosContactsAdd;

  /// No description provided for @sosContactsCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get sosContactsCall;

  /// No description provided for @sosContactsSms.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get sosContactsSms;

  /// No description provided for @subscriptionPaywallTitle.
  ///
  /// In fr, this message translates to:
  /// **'KimiaCare Premium'**
  String get subscriptionPaywallTitle;

  /// No description provided for @subscriptionPaywallSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Débloquez toutes les fonctionnalités'**
  String get subscriptionPaywallSubtitle;

  /// No description provided for @subscriptionCtaStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer maintenant'**
  String get subscriptionCtaStart;

  /// No description provided for @subscriptionRestorePurchases.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer les achats'**
  String get subscriptionRestorePurchases;

  /// No description provided for @subscriptionPeriodMonthly.
  ///
  /// In fr, this message translates to:
  /// **'Mensuel'**
  String get subscriptionPeriodMonthly;

  /// No description provided for @subscriptionPeriodYearly.
  ///
  /// In fr, this message translates to:
  /// **'Annuel  −20%'**
  String get subscriptionPeriodYearly;

  /// No description provided for @subscriptionPeriodLifetime.
  ///
  /// In fr, this message translates to:
  /// **'une fois'**
  String get subscriptionPeriodLifetime;

  /// No description provided for @subscriptionTrialNote.
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit {days} jours — annulation à tout moment'**
  String subscriptionTrialNote(int days);

  /// No description provided for @subscriptionStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon abonnement'**
  String get subscriptionStatusTitle;

  /// No description provided for @subscriptionStatusFree.
  ///
  /// In fr, this message translates to:
  /// **'Gratuit'**
  String get subscriptionStatusFree;

  /// No description provided for @subscriptionStatusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get subscriptionStatusActive;

  /// No description provided for @subscriptionStatusTrial.
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit'**
  String get subscriptionStatusTrial;

  /// No description provided for @subscriptionStatusExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get subscriptionStatusExpired;

  /// No description provided for @subscriptionUpgradeCta.
  ///
  /// In fr, this message translates to:
  /// **'Voir les plans'**
  String get subscriptionUpgradeCta;

  /// No description provided for @subscriptionManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer l\'abonnement'**
  String get subscriptionManage;

  /// No description provided for @subscriptionManageSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier ou annuler via l\'App Store / Google Play'**
  String get subscriptionManageSubtitle;

  /// No description provided for @subscriptionWillNotRenew.
  ///
  /// In fr, this message translates to:
  /// **'Votre abonnement ne sera pas renouvelé.'**
  String get subscriptionWillNotRenew;

  /// No description provided for @subscriptionUpgradeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Premium'**
  String get subscriptionUpgradeTitle;

  /// No description provided for @subscriptionUpgradeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Débloquez la blacklist illimitée, les profils enfants et le suivi fitness avancé.'**
  String get subscriptionUpgradeSubtitle;

  /// No description provided for @moduleMeditationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Méditation'**
  String get moduleMeditationTitle;

  /// No description provided for @moduleMeditationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sessions guidées'**
  String get moduleMeditationSubtitle;

  /// No description provided for @moduleMeditationBadge.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get moduleMeditationBadge;

  /// No description provided for @splashTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre sanctuaire numérique'**
  String get splashTagline;

  /// No description provided for @splashCtaButton.
  ///
  /// In fr, this message translates to:
  /// **'Entrer dans KimiaCare'**
  String get splashCtaButton;

  /// No description provided for @messageDetailTypeSms.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get messageDetailTypeSms;

  /// No description provided for @messageDetailTypeWhatsapp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get messageDetailTypeWhatsapp;

  /// No description provided for @messageDetailTypeSignal.
  ///
  /// In fr, this message translates to:
  /// **'Signal'**
  String get messageDetailTypeSignal;

  /// No description provided for @messageDetailTypeTelegram.
  ///
  /// In fr, this message translates to:
  /// **'Telegram'**
  String get messageDetailTypeTelegram;

  /// No description provided for @messageDetailMarkRead.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme lu'**
  String get messageDetailMarkRead;

  /// No description provided for @messageDetailBlockContact.
  ///
  /// In fr, this message translates to:
  /// **'Bloquer ce contact'**
  String get messageDetailBlockContact;

  /// No description provided for @callFilterRulesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Filtrage des appels'**
  String get callFilterRulesTitle;

  /// No description provided for @callFilterRulesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les numéros autorisés ou bloqués'**
  String get callFilterRulesSubtitle;

  /// No description provided for @callFilterModeBlacklist.
  ///
  /// In fr, this message translates to:
  /// **'Liste noire'**
  String get callFilterModeBlacklist;

  /// No description provided for @callFilterModeWhitelist.
  ///
  /// In fr, this message translates to:
  /// **'Liste blanche'**
  String get callFilterModeWhitelist;

  /// No description provided for @callFilterModeBlacklistDesc.
  ///
  /// In fr, this message translates to:
  /// **'Tous les appels sont autorisés sauf les numéros listés'**
  String get callFilterModeBlacklistDesc;

  /// No description provided for @callFilterModeWhitelistDesc.
  ///
  /// In fr, this message translates to:
  /// **'Seuls les numéros listés peuvent appeler'**
  String get callFilterModeWhitelistDesc;

  /// No description provided for @callFilterRulesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun numéro dans la liste'**
  String get callFilterRulesEmpty;

  /// No description provided for @callFilterRulesEmptyDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des numéros à bloquer ou autoriser selon le mode actif'**
  String get callFilterRulesEmptyDesc;

  /// No description provided for @callFilterAddRule.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un numéro'**
  String get callFilterAddRule;

  /// No description provided for @callFilterPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get callFilterPhoneLabel;

  /// No description provided for @callFilterPhoneHint.
  ///
  /// In fr, this message translates to:
  /// **'+33 6 12 34 56 78'**
  String get callFilterPhoneHint;

  /// No description provided for @callFilterLabelOptional.
  ///
  /// In fr, this message translates to:
  /// **'Étiquette (optionnel)'**
  String get callFilterLabelOptional;

  /// No description provided for @callFilterTypeBlacklist.
  ///
  /// In fr, this message translates to:
  /// **'Bloqué'**
  String get callFilterTypeBlacklist;

  /// No description provided for @callFilterTypeWhitelist.
  ///
  /// In fr, this message translates to:
  /// **'Autorisé'**
  String get callFilterTypeWhitelist;

  /// No description provided for @callFilterDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette règle ?'**
  String get callFilterDeleteConfirm;

  /// No description provided for @callFilterDeleteContent.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro sera retiré de la liste.'**
  String get callFilterDeleteContent;

  /// No description provided for @callFilterDuplicateError.
  ///
  /// In fr, this message translates to:
  /// **'Ce numéro est déjà dans la liste'**
  String get callFilterDuplicateError;

  /// No description provided for @callFilterSaveError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'enregistrement'**
  String get callFilterSaveError;

  /// No description provided for @callFilterLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement des règles'**
  String get callFilterLoadError;

  /// No description provided for @callFilterDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get callFilterDeleteError;

  /// No description provided for @callFilterInfoBanner.
  ///
  /// In fr, this message translates to:
  /// **'Les numéros ajoutés ici sont appliqués automatiquement sur l\'appareil de l\'enfant.'**
  String get callFilterInfoBanner;

  /// No description provided for @callFilterPhoneEmptyError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un numéro'**
  String get callFilterPhoneEmptyError;

  /// No description provided for @blockedCallsLogTitle.
  ///
  /// In fr, this message translates to:
  /// **'APPELS BLOQUÉS'**
  String get blockedCallsLogTitle;

  /// No description provided for @blockedCallsLogEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appel bloqué récemment'**
  String get blockedCallsLogEmpty;

  /// No description provided for @blockedCallsLogLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les appels bloqués.'**
  String get blockedCallsLogLoadError;

  /// No description provided for @blockedCallsLogBadgeBlacklist.
  ///
  /// In fr, this message translates to:
  /// **'Liste noire'**
  String get blockedCallsLogBadgeBlacklist;

  /// No description provided for @blockedCallsLogBadgeWhitelist.
  ///
  /// In fr, this message translates to:
  /// **'Liste blanche'**
  String get blockedCallsLogBadgeWhitelist;

  /// No description provided for @greetingMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonne matinée 🌅'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bonne après-midi ☀'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir 🌙'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In fr, this message translates to:
  /// **'Belle nuit 🌟'**
  String get greetingNight;

  /// No description provided for @welcomeStatsFiltered.
  ///
  /// In fr, this message translates to:
  /// **'{count} messages filtrés aujourd\'hui'**
  String welcomeStatsFiltered(int count);

  /// No description provided for @welcomeStatsSteps.
  ///
  /// In fr, this message translates to:
  /// **'{current} / {goal} pas'**
  String welcomeStatsSteps(int current, int goal);

  /// No description provided for @welcomeStatsEvents.
  ///
  /// In fr, this message translates to:
  /// **'{count} événements aujourd\'hui'**
  String welcomeStatsEvents(int count);
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
