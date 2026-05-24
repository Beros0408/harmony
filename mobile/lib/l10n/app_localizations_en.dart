// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Harmony';

  @override
  String get dashboardTitle => 'Harmony';

  @override
  String get dashboardWelcomeWave => 'Welcome 👋';

  @override
  String get dashboardAllServicesActive => 'All services active';

  @override
  String get dashboardSectionModules => 'MY MODULES';

  @override
  String get moduleSecurityTitle => 'Security';

  @override
  String get moduleSecuritySubtitle => 'Active filtering';

  @override
  String get moduleSecurityBadge => 'active';

  @override
  String get moduleFamilyTitle => 'Family';

  @override
  String get moduleFamilySubtitle => 'Parental control';

  @override
  String moduleFamilyBadgeProfiles(int count) {
    return '$count profiles';
  }

  @override
  String get moduleFitnessTitle => 'Fitness';

  @override
  String moduleFitnessSubtitle(int current, int goal) {
    return '$current / $goal steps';
  }

  @override
  String get moduleFitnessBadge => 'ongoing';

  @override
  String get moduleAgendaTitle => 'Agenda';

  @override
  String moduleAgendaSubtitle(int count) {
    return '$count events';
  }

  @override
  String get moduleAgendaBadge => 'today';

  @override
  String get navBack => 'Back';

  @override
  String get navBackToDashboard => 'Back to dashboard';

  @override
  String get securityScreenTitle => 'Security & Filtering';

  @override
  String get securityStatsBlocked => 'Blocked';

  @override
  String get securityStatsRules => 'Rules';

  @override
  String get securityStatsPrecision => 'Accuracy';

  @override
  String get securitySectionActiveMode => 'ACTIVE MODE';

  @override
  String get securityModeNormal => 'Normal Mode';

  @override
  String get securityModeFocus => 'Focus Mode';

  @override
  String get securityModeNight => 'Night Mode';

  @override
  String get securitySectionRules => 'FILTERING RULES';

  @override
  String get securityRuleUnknownNumbers => 'Unknown numbers';

  @override
  String get securityRuleUnknownNumbersDesc => 'Block all unidentified calls';

  @override
  String get securityRuleSpam => 'Cold calls';

  @override
  String get securityRuleSpamDesc => 'AI detection of commercial calls';

  @override
  String get securityRuleBlacklist => 'Personal blacklist';

  @override
  String securityRuleBlacklistDesc(int count) {
    return '$count numbers';
  }

  @override
  String get securityRuleForeign => 'Foreign numbers';

  @override
  String get securityRuleForeignDesc => 'International area codes';

  @override
  String get securityRuleWhitelist => 'Family whitelist';

  @override
  String securityRuleWhitelistDesc(int count) {
    return '$count contacts always allowed';
  }

  @override
  String get securitySectionRecentBlocked => 'RECENTLY BLOCKED CALLS';

  @override
  String get securitySeeAll => 'See all';

  @override
  String get familyScreenTitle => 'Family & Parental Control';

  @override
  String get familySectionChildren => 'MY CHILDREN';

  @override
  String familyChildAge(String name, int age) {
    return '$name, $age years old';
  }

  @override
  String get familyStatusAtSchool => 'At school';

  @override
  String get familyStatusAtHome => 'At home';

  @override
  String familyScoreLabel(int value) {
    return 'Score $value';
  }

  @override
  String familyChildDetailsToast(String name) {
    return 'Details for $name coming in Sprint 2';
  }

  @override
  String get familySectionLocation => 'REAL-TIME LOCATION';

  @override
  String get familyMapPlaceholderTitle => 'Interactive map coming soon';

  @override
  String get familyMapPlaceholderSubtitle => 'Google Maps — Sprint 2';

  @override
  String get familySectionZones => 'SAFE ZONES';

  @override
  String get familyZoneHome => 'Home';

  @override
  String get familyZoneHomeDesc => '250m radius · Active 24/7';

  @override
  String get familyZoneSchool => 'École Jules Ferry';

  @override
  String get familyZoneSchoolDesc => '100m radius · Mon-Fri 8am-5pm';

  @override
  String get familyZoneStadium => 'Municipal Stadium';

  @override
  String get familyZoneStadiumDesc => '150m radius · Wed-Sat afternoons';

  @override
  String get familySectionLimits => 'DAILY LIMITS';

  @override
  String get familyLimitScreen => 'Screen time today';

  @override
  String get familyLimitDistance => 'Distance from home';

  @override
  String get fitnessScreenTitle => 'Fitness & Performance';

  @override
  String get fitnessSectionToday => 'TODAY';

  @override
  String get fitnessSteps => 'Steps';

  @override
  String fitnessStepsGoal(int goal) {
    return '/ $goal goal';
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
  String get fitnessHeartRate => 'Avg BPM';

  @override
  String get fitnessHeartRateUnit => 'bpm';

  @override
  String get fitnessSectionWeekly => 'WEEKLY ACTIVITY';

  @override
  String get fitnessWeekdayMon => 'M';

  @override
  String get fitnessWeekdayTue => 'T';

  @override
  String get fitnessWeekdayWed => 'W';

  @override
  String get fitnessWeekdayThu => 'T';

  @override
  String get fitnessWeekdayFri => 'F';

  @override
  String get fitnessWeekdaySat => 'S';

  @override
  String get fitnessWeekdaySun => 'S';

  @override
  String get fitnessSectionRecords => 'MY RECORDS';

  @override
  String get fitnessRecordLongestWalk => 'Longest walk';

  @override
  String get fitnessRecordLongestWalkDesc => '12.5 km · 2 weeks ago';

  @override
  String get fitnessRecordMostSteps => 'Most steps in 1 day';

  @override
  String get fitnessRecordMostStepsDesc => '14,832 steps · 1 month ago';

  @override
  String get fitnessRecordFastestRun => 'Fastest run';

  @override
  String get fitnessRecordFastestRunDesc => '5km in 28 min · 3 days ago';

  @override
  String get fitnessSectionSessions => 'RECENT SESSIONS';

  @override
  String get fitnessSessionWalk => 'Walk';

  @override
  String get fitnessSessionWalkDesc => '35min · 3.2km · yesterday 6:12pm';

  @override
  String get fitnessSessionRun => 'Run';

  @override
  String get fitnessSessionRunDesc => '28min · 5km · 3 days ago';

  @override
  String get fitnessSessionBike => 'Cycling';

  @override
  String get fitnessSessionBikeDesc => '1h12 · 18km · 5 days ago';

  @override
  String get agendaScreenTitle => 'Agenda & Planning';

  @override
  String get agendaDateToday => 'Today';

  @override
  String get agendaNavigationToast => 'Day navigation coming soon';

  @override
  String get agendaSectionModes => 'DAY MODES';

  @override
  String get agendaModeFocus => 'Focus';

  @override
  String get agendaModeFocusDesc => 'Limited notifications';

  @override
  String get agendaModeSleep => 'Sleep';

  @override
  String get agendaModeSleepDesc => 'Scheduled 10pm-7am';

  @override
  String get agendaSectionEvents => 'TODAY\'S EVENTS';

  @override
  String get agendaEventMeeting => 'Product team meeting';

  @override
  String get agendaEventMeetingTime => '2:00pm–3:00pm · Office';

  @override
  String agendaEventMeetingDetail(int count) {
    return '$count participants';
  }

  @override
  String get agendaEventDinner => 'Dinner with parents';

  @override
  String get agendaEventDinnerTime => '7:30pm–9:00pm · Home';

  @override
  String get agendaEventDinnerDetail => 'Home';

  @override
  String get agendaEventYoga => 'Yoga class';

  @override
  String get agendaEventYogaTime => '6:00pm–7:00pm';

  @override
  String get agendaEventYogaDetail => 'Studio Mahalo';

  @override
  String get agendaCreateButton => 'New event';

  @override
  String get agendaCreateToast => 'Event creation coming in Sprint 4';

  @override
  String get authWelcomeTitle => 'Welcome to Harmony';

  @override
  String get authCreatePinTitle => 'Create your PIN';

  @override
  String get authChoosePin => 'Choose a 4-digit code';

  @override
  String get authConfirmPinTitle => 'Confirm your PIN';

  @override
  String get authReenterPin => 'Re-enter your PIN';

  @override
  String get authEnterPin => 'Enter your PIN';

  @override
  String get authPinMismatch => 'Codes do not match';

  @override
  String get authIncorrectCode => 'Incorrect code';

  @override
  String authAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts remaining',
      one: '1 attempt remaining',
    );
    return '$_temp0';
  }

  @override
  String get authBiometricSetupTitle => 'Enable biometrics?';

  @override
  String get authBiometricSetupDesc =>
      'Unlock Harmony with Face ID or your fingerprint.';

  @override
  String get authBiometricEnable => 'Enable';

  @override
  String get authBiometricLater => 'Later';

  @override
  String get authBiometricSkip => 'Skip';

  @override
  String get emptyStateComingSoon => 'Coming soon';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

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
  String get settingsTheme => 'Appearance';

  @override
  String get settingsThemeSystem => 'Automatic';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get moduleContactsTitle => 'Contacts';

  @override
  String get moduleContactsSubtitle => 'Contact management';

  @override
  String moduleContactsBadge(int count) {
    return '$count contacts';
  }

  @override
  String get contactsScreenTitle => 'Contacts';

  @override
  String get contactsSectionWhitelist => 'WHITELIST';

  @override
  String get contactsSectionBlacklist => 'BLACKLIST';

  @override
  String get contactsAddContact => 'Add a contact';

  @override
  String get contactsWhitelistBadge => 'allowed';

  @override
  String get contactsBlacklistBadge => 'blocked';

  @override
  String get contactsEmpty => 'No contacts';

  @override
  String get contactsRemove => 'Remove';

  @override
  String get voicemailScreenTitle => 'Voicemail';

  @override
  String voicemailNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new messages',
      one: '1 new message',
      zero: 'No new messages',
    );
    return '$_temp0';
  }

  @override
  String voicemailTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages total',
      one: '1 message total',
    );
    return '$_temp0';
  }

  @override
  String get voicemailPushInfo => 'Push simulation enabled';

  @override
  String get voicemailMarkRead => 'Mark as read';

  @override
  String get voicemailDelete => 'Delete';

  @override
  String get voicemailCallBack => 'Call back';

  @override
  String get voicemailUrgent => 'Urgent';

  @override
  String get voicemailNewMessageToastTitle => 'New voicemail';

  @override
  String voicemailNewMessageToastBody(String name) {
    return 'Message from $name';
  }

  @override
  String get voicemailViewButton => 'View';

  @override
  String get voicemailTranscriptionLabel => 'Transcription';

  @override
  String get voicemailExpandHint => 'View transcription';

  @override
  String get voicemailMockNote =>
      'Simulated transcriptions — real STT in Sprint 5';

  @override
  String get voicemailPlay => 'Play';

  @override
  String get callScreeningEnableTitle => 'Enable protection';

  @override
  String get callScreeningEnableDescription =>
      'To block unwanted calls, Harmony must be your default call screening app';

  @override
  String get callScreeningEnableButton => 'Enable';

  @override
  String get callScreeningActiveStatus => 'Protection active';

  @override
  String get callLogScreenTitle => 'Block log';

  @override
  String get callLogFilterToday => 'Today';

  @override
  String get callLogFilterWeek => 'This week';

  @override
  String get callLogFilterAll => 'All';

  @override
  String get callLogEmptyState => 'No blocked calls';

  @override
  String get callLogClearAllButton => 'Clear all';
}
