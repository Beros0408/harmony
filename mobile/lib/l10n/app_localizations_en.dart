// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'KimiaCare';

  @override
  String get dashboardTitle => 'KimiaCare';

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
  String get authWelcomeTitle => 'Welcome to KimiaCare';

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
      'Unlock KimiaCare with Face ID or your fingerprint.';

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
  String get contactsPermissionTitle => 'Contacts access required';

  @override
  String get contactsPermissionSubtitle =>
      'KimiaCare needs your permission to display your address book.';

  @override
  String get contactsPermissionCta => 'Grant contacts access';

  @override
  String get blacklistPickFromContacts => 'Pick from contacts';

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
      'To block unwanted calls, KimiaCare must be your default call screening app';

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

  @override
  String get iosFilteringTitle => 'iOS Filtering';

  @override
  String get iosFilteringInstructions =>
      'To enable call blocking on iOS, activate the extension in Settings.';

  @override
  String get iosFilteringStep1 =>
      'Open Settings → Phone → Call Blocking & Identification';

  @override
  String get iosFilteringStep2 => 'Enable KimiaCare in the list';

  @override
  String get iosFilteringOpenSettingsButton => 'Open settings';

  @override
  String get outgoingCallAlertTitle => 'Potentially premium-rate call';

  @override
  String outgoingCallAlertEstimatedCost(String cost) {
    return 'Estimated cost: $cost €/min';
  }

  @override
  String get outgoingCallAlertCancel => 'Cancel';

  @override
  String get outgoingCallAlertContinueButton => 'Continue call';

  @override
  String get outgoingCallAlertDontAskAgain =>
      'Don\'t ask again for this number';

  @override
  String get filterModeOff => 'Off';

  @override
  String get filterModeNight => 'Night';

  @override
  String get filterModeWork => 'Work';

  @override
  String get filterModeFocus => 'Focus';

  @override
  String get filterModeWeekend => 'Weekend';

  @override
  String get filterModeEmergency => 'Emergency';

  @override
  String get filterModeActivate => 'Activate';

  @override
  String get filterModeConfigure => 'Configure';

  @override
  String get filterModeCurrentActive => 'Active mode';

  @override
  String get blacklistScreenTitle => 'Blocklist';

  @override
  String get blacklistSearchHint => 'Search a number or label...';

  @override
  String get blacklistEmptyTitle => 'No blocked numbers';

  @override
  String get blacklistAddTitle => 'Add a number';

  @override
  String get blacklistEditTitle => 'Edit entry';

  @override
  String get blacklistPhoneLabel => 'Phone number';

  @override
  String get blacklistPhoneHint => '+33 6 12 34 56 78';

  @override
  String get blacklistLabelHint => 'Label (optional)';

  @override
  String get blacklistReasonLabel => 'Block reason';

  @override
  String get blacklistSaveButton => 'Save';

  @override
  String get blacklistReasonSpam => 'Spam';

  @override
  String get blacklistReasonTelemarketing => 'Telemarketing';

  @override
  String get blacklistReasonHarassment => 'Harassment';

  @override
  String get blacklistReasonOther => 'Other';

  @override
  String get familyChildrenSection => 'MY CHILDREN';

  @override
  String get familyMapSection => 'REAL-TIME LOCATION';

  @override
  String get familyZonesSection => 'SAFE ZONES';

  @override
  String get familyAddZoneFAB => 'Add zone';

  @override
  String get childDetailTitle => 'Child detail';

  @override
  String childAtZone(String name) {
    return 'At: $name';
  }

  @override
  String get childInTransit => 'In transit';

  @override
  String childSecurityScore(int value) {
    return 'Score $value';
  }

  @override
  String get zoneEditorAddTitle => 'New zone';

  @override
  String get zoneEditorEditTitle => 'Edit zone';

  @override
  String get zoneFieldName => 'Zone name';

  @override
  String get zoneFieldRadius => 'Radius';

  @override
  String get zoneFieldIcon => 'Icon';

  @override
  String get zoneIconHome => 'Home';

  @override
  String get zoneIconSchool => 'School';

  @override
  String get zoneIconSport => 'Sport';

  @override
  String get zoneIconOther => 'Other';

  @override
  String get sosButtonLabel => 'SOS';

  @override
  String get sosHoldHint => 'Hold 3 seconds to trigger';

  @override
  String get sosActiveTitle => 'SOS ACTIVE';

  @override
  String get sosActiveCountdown => 'Calling in';

  @override
  String get sosActiveCancel => 'Cancel SOS';

  @override
  String get sosCancelConfirm => 'Are you safe?';

  @override
  String get sosTriggerConfirmTitle => 'Send a SOS alert?';

  @override
  String get sosTriggerConfirmMessage =>
      'Your parent will be notified immediately with your location.';

  @override
  String get sosTriggerConfirmCancel => 'Cancel';

  @override
  String get sosTriggerConfirmSend => 'Send SOS';

  @override
  String get sosSentSuccess => 'SOS sent, your parent has been alerted';

  @override
  String get sosSentError => 'Unable to send SOS, check your connection';

  @override
  String get sosSectionTitle => 'SOS ALERTS';

  @override
  String get sosNoActive => 'No SOS alert — all is well.';

  @override
  String get sosAcknowledge => 'Got it — Acknowledge';

  @override
  String sosPosition(String lat, String lon) {
    return 'Location: $lat, $lon';
  }

  @override
  String get sosViewOnMap => 'View on map';

  @override
  String get sosLoadError => 'Unable to load SOS alerts.';

  @override
  String get sosAckError => 'Unable to acknowledge the alert.';

  @override
  String get permissionLocationTitle => 'Location required';

  @override
  String get permissionLocationBody =>
      'KimiaCare needs your location to monitor safe zones';

  @override
  String get permissionLocationGrant => 'Allow';

  @override
  String get agendaNoEvents => 'No events';

  @override
  String get agendaTasksShortcut => 'My tasks';

  @override
  String get agendaGoogleShortcut => 'Google Calendar';

  @override
  String get agendaEventDetailTitle => 'Details';

  @override
  String get agendaEventEdit => 'Edit';

  @override
  String get agendaEventImportant => 'Mark important';

  @override
  String get agendaEventDelete => 'Delete';

  @override
  String get agendaEventDeleteConfirm => 'Delete this event?';

  @override
  String get agendaEventDeleteConfirmYes => 'Delete';

  @override
  String get agendaEventDeleteConfirmNo => 'Cancel';

  @override
  String get agendaEventLocation => 'Location';

  @override
  String get agendaEventReminder => 'Reminder';

  @override
  String agendaEventReminderMinutes(int n) {
    return '$n min before';
  }

  @override
  String get agendaEventRecurrence => 'Recurrence';

  @override
  String get agendaEditorNewTitle => 'New event';

  @override
  String get agendaEditorEditTitle => 'Edit event';

  @override
  String get agendaEditorSave => 'Save';

  @override
  String get agendaEditorFieldTitle => 'Title';

  @override
  String get agendaEditorFieldDescription => 'Description (optional)';

  @override
  String get agendaEditorFieldLocation => 'Location (optional)';

  @override
  String get agendaEditorFieldStart => 'Start';

  @override
  String get agendaEditorFieldEnd => 'End';

  @override
  String get agendaEditorFieldReminder => 'Reminder';

  @override
  String get agendaEditorFieldCategory => 'Category';

  @override
  String get agendaEditorMarkImportant => 'Mark as important';

  @override
  String get agendaEditorValidationTitle => 'Title required';

  @override
  String get agendaTasksTitle => 'My Tasks';

  @override
  String get agendaTasksQuadrantDoFirst => 'Urgent & Important';

  @override
  String get agendaTasksQuadrantSchedule => 'Important, not urgent';

  @override
  String get agendaTasksQuadrantDelegate => 'Urgent, not important';

  @override
  String get agendaTasksQuadrantDelete => 'Neither urgent nor important';

  @override
  String get agendaTasksEmpty => 'No tasks';

  @override
  String get agendaTasksAdd => 'New task';

  @override
  String get agendaGoogleTitle => 'Google Calendar';

  @override
  String get agendaGoogleConnectButton => 'Connect Google Calendar';

  @override
  String get agendaGoogleConnectedAs => 'Connected as';

  @override
  String get agendaGoogleDisconnect => 'Disconnect';

  @override
  String get agendaGoogleSync => 'Sync';

  @override
  String get agendaGoogleSyncing => 'Syncing...';

  @override
  String get agendaGoogleLastSync => 'Last sync';

  @override
  String get agendaGoogleNotConnected => 'Not connected';

  @override
  String get agendaCategorySport => 'Sport';

  @override
  String get agendaCategoryMedical => 'Medical';

  @override
  String get agendaCategoryProfessional => 'Professional';

  @override
  String get agendaCategorySchool => 'School';

  @override
  String get agendaCategoryLeisure => 'Leisure';

  @override
  String get agendaCategoryOther => 'Other';

  @override
  String get messagesModuleTitle => 'Messages';

  @override
  String get messagesModuleSubtitle => 'WhatsApp · Signal · SMS';

  @override
  String get messagesModuleBadge => 'active';

  @override
  String get messagesScreenTitle => 'Messages & SMS';

  @override
  String get messagesRefreshTooltip => 'Refresh messages';

  @override
  String get messagesListenerEnabledTitle => 'Notification access active';

  @override
  String get messagesListenerEnabledSubtitle =>
      'WhatsApp, Signal and Telegram are monitored';

  @override
  String get messagesListenerDisabledTitle => 'Notification access required';

  @override
  String get messagesListenerDisabledSubtitle =>
      'Enable access to capture WhatsApp, Signal and Telegram';

  @override
  String get messagesListenerEnableCta => 'Enable access';

  @override
  String get messagesSectionRules => 'FILTERING RULES';

  @override
  String get messagesSectionRecent => 'RECENT MESSAGES';

  @override
  String get messagesStatTotal => 'Received';

  @override
  String get messagesStatBlocked => 'Blocked';

  @override
  String get messagesStatRules => 'Rules';

  @override
  String get messagesEmptyState =>
      'No messages captured.\nEnable notification access\nthen send an SMS or WhatsApp message.';

  @override
  String get messagesIosLimitation =>
      'iOS: WhatsApp and Signal cannot be intercepted by KimiaCare due to Apple sandboxing. Only SMS can be filtered via SMS Filter Extension. Use Screen Time to restrict WhatsApp on iOS.';

  @override
  String get messagesPermissionRequiredTitle => 'SMS permission required';

  @override
  String get messagesPermissionRequiredSubtitle =>
      'Enable SMS access to view messages in KimiaCare';

  @override
  String get messagesPermissionAllowCta => 'Allow';

  @override
  String get messagesPermissionDeniedSnack =>
      'SMS permission denied. You can enable it in the app settings.';

  @override
  String get messageBlockedBadge => 'Blocked';

  @override
  String get messageRuleNewTitle => 'New rule';

  @override
  String get messageRuleEditTitle => 'Edit rule';

  @override
  String get messageRuleLabelType => 'Rule type';

  @override
  String get messageRuleLabelContact => 'Number or name';

  @override
  String get messageRuleLabelKeyword => 'Keyword';

  @override
  String get messageRuleHintKeyword => 'spam, ads, promo...';

  @override
  String get messageRulePickContacts => 'Pick from contacts';

  @override
  String get messageRuleScheduleInfo =>
      'Time range: the rule applies between these hours';

  @override
  String get messageRuleScheduleLabel => 'Range (e.g. 22-7)';

  @override
  String get messageRuleLabelAction => 'Action';

  @override
  String get messageRuleLabelSources => 'Sources';

  @override
  String get messageRuleSourcesAll => 'Leave empty to apply to all sources';

  @override
  String get messageRuleValidationEmpty => 'Please enter a value';

  @override
  String get messageRuleAddButton => 'Add rule';

  @override
  String get messageRuleEditButton => 'Save';

  @override
  String get messageRuleScheduleDisplay => '(time range)';

  @override
  String get fitnessPermissionTitle => 'Activity access required';

  @override
  String get fitnessPermissionSubtitle =>
      'KimiaCare needs permission to count your steps and track your activity';

  @override
  String get fitnessPermissionAllowCta => 'Allow access';

  @override
  String get fitnessGoalTitle => 'DAILY GOAL';

  @override
  String fitnessGoalSteps(int count) {
    return '$count steps / day';
  }

  @override
  String get fitnessStartWorkout => 'Start workout';

  @override
  String get fitnessStopWorkout => 'Stop';

  @override
  String get fitnessWorkoutRunning => 'Workout in progress';

  @override
  String get fitnessActiveMinutes => 'Active min.';

  @override
  String get fitnessWorkoutTypeWalk => 'Walk';

  @override
  String get fitnessWorkoutTypeRun => 'Run';

  @override
  String get fitnessWorkoutTypeCycle => 'Cycling';

  @override
  String get childSettingsTitle => 'Child settings';

  @override
  String get sosContactsTitle => 'SOS contacts';

  @override
  String get sosContactsEmpty => 'No SOS contacts';

  @override
  String get sosContactsAdd => 'Add a contact';

  @override
  String get sosContactsCall => 'Call';

  @override
  String get sosContactsSms => 'SMS';

  @override
  String get subscriptionPaywallTitle => 'KimiaCare Premium';

  @override
  String get subscriptionPaywallSubtitle => 'Unlock all features';

  @override
  String get subscriptionCtaStart => 'Get started';

  @override
  String get subscriptionRestorePurchases => 'Restore purchases';

  @override
  String get subscriptionPeriodMonthly => 'Monthly';

  @override
  String get subscriptionPeriodYearly => 'Yearly  −20%';

  @override
  String get subscriptionPeriodLifetime => 'once';

  @override
  String subscriptionTrialNote(int days) {
    return '$days-day free trial — cancel anytime';
  }

  @override
  String get subscriptionStatusTitle => 'My subscription';

  @override
  String get subscriptionStatusFree => 'Free';

  @override
  String get subscriptionStatusActive => 'Active';

  @override
  String get subscriptionStatusTrial => 'Free trial';

  @override
  String get subscriptionStatusExpired => 'Expired';

  @override
  String get subscriptionUpgradeCta => 'View plans';

  @override
  String get subscriptionManage => 'Manage subscription';

  @override
  String get subscriptionManageSubtitle =>
      'Edit or cancel via App Store / Google Play';

  @override
  String get subscriptionWillNotRenew =>
      'Your subscription will not be renewed.';

  @override
  String get subscriptionUpgradeTitle => 'Go Premium';

  @override
  String get subscriptionUpgradeSubtitle =>
      'Unlock unlimited blacklist, child profiles and advanced fitness tracking.';

  @override
  String get moduleMeditationTitle => 'Meditation';

  @override
  String get moduleMeditationSubtitle => 'Guided sessions';

  @override
  String get moduleMeditationBadge => 'New';

  @override
  String get splashTagline => 'Your digital sanctuary';

  @override
  String get splashCtaButton => 'Enter KimiaCare';

  @override
  String get messageDetailTypeSms => 'SMS';

  @override
  String get messageDetailTypeWhatsapp => 'WhatsApp';

  @override
  String get messageDetailTypeSignal => 'Signal';

  @override
  String get messageDetailTypeTelegram => 'Telegram';

  @override
  String get messageDetailMarkRead => 'Mark as read';

  @override
  String get messageDetailBlockContact => 'Block this contact';

  @override
  String get callFilterRulesTitle => 'Call Filtering';

  @override
  String get callFilterRulesSubtitle => 'Manage allowed or blocked numbers';

  @override
  String get callFilterModeBlacklist => 'Blacklist';

  @override
  String get callFilterModeWhitelist => 'Whitelist';

  @override
  String get callFilterModeBlacklistDesc =>
      'All calls are allowed except listed numbers';

  @override
  String get callFilterModeWhitelistDesc => 'Only listed numbers can call';

  @override
  String get callFilterRulesEmpty => 'No numbers in the list';

  @override
  String get callFilterRulesEmptyDesc =>
      'Add numbers to block or allow based on the active mode';

  @override
  String get callFilterAddRule => 'Add a number';

  @override
  String get callFilterPhoneLabel => 'Phone number';

  @override
  String get callFilterPhoneHint => '+1 555 000 0000';

  @override
  String get callFilterLabelOptional => 'Label (optional)';

  @override
  String get callFilterTypeBlacklist => 'Blocked';

  @override
  String get callFilterTypeWhitelist => 'Allowed';

  @override
  String get callFilterDeleteConfirm => 'Delete this rule?';

  @override
  String get callFilterDeleteContent =>
      'This number will be removed from the list.';

  @override
  String get callFilterDuplicateError => 'This number is already in the list';

  @override
  String get callFilterSaveError => 'Error saving rule';

  @override
  String get callFilterLoadError => 'Error loading rules';

  @override
  String get callFilterDeleteError => 'Error deleting rule';

  @override
  String get callFilterInfoBanner =>
      'Numbers added here are automatically applied to the child\'s device.';

  @override
  String get callFilterPhoneEmptyError => 'Please enter a number';

  @override
  String get blockedCallsLogTitle => 'BLOCKED CALLS';

  @override
  String get blockedCallsLogEmpty => 'No calls blocked recently';

  @override
  String get blockedCallsLogLoadError => 'Unable to load blocked calls.';

  @override
  String get blockedCallsLogBadgeBlacklist => 'Blacklist';

  @override
  String get blockedCallsLogBadgeWhitelist => 'Whitelist';

  @override
  String get greetingMorning => 'Good morning 🌅';

  @override
  String get greetingAfternoon => 'Good afternoon ☀';

  @override
  String get greetingEvening => 'Good evening 🌙';

  @override
  String get greetingNight => 'Good night 🌟';

  @override
  String welcomeStatsFiltered(int count) {
    return '$count filtered messages today';
  }

  @override
  String welcomeStatsSteps(int current, int goal) {
    return '$current / $goal steps';
  }

  @override
  String welcomeStatsEvents(int count) {
    return '$count events today';
  }
}
