// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Harmony';

  @override
  String get dashboardTitle => 'Harmony';

  @override
  String get dashboardWelcomeWave => 'Benvenuto 👋';

  @override
  String get dashboardAllServicesActive => 'Tutti i servizi attivi';

  @override
  String get dashboardSectionModules => 'I MIEI MODULI';

  @override
  String get moduleSecurityTitle => 'Sicurezza';

  @override
  String get moduleSecuritySubtitle => 'Filtraggio attivo';

  @override
  String get moduleSecurityBadge => 'attivo';

  @override
  String get moduleFamilyTitle => 'Famiglia';

  @override
  String get moduleFamilySubtitle => 'Controllo parentale';

  @override
  String moduleFamilyBadgeProfiles(int count) {
    return '$count profili';
  }

  @override
  String get moduleFitnessTitle => 'Fitness';

  @override
  String moduleFitnessSubtitle(int current, int goal) {
    return '$current / $goal passi';
  }

  @override
  String get moduleFitnessBadge => 'in corso';

  @override
  String get moduleAgendaTitle => 'Agenda';

  @override
  String moduleAgendaSubtitle(int count) {
    return '$count eventi';
  }

  @override
  String get moduleAgendaBadge => 'oggi';

  @override
  String get navBack => 'Indietro';

  @override
  String get navBackToDashboard => 'Torna alla dashboard';

  @override
  String get securityScreenTitle => 'Sicurezza e Filtraggio';

  @override
  String get securityStatsBlocked => 'Bloccati';

  @override
  String get securityStatsRules => 'Regole';

  @override
  String get securityStatsPrecision => 'Precisione';

  @override
  String get securitySectionActiveMode => 'MODALITÀ ATTIVA';

  @override
  String get securityModeNormal => 'Modalità Normale';

  @override
  String get securityModeFocus => 'Modalità Focus';

  @override
  String get securityModeNight => 'Modalità Notte';

  @override
  String get securitySectionRules => 'REGOLE DI FILTRAGGIO';

  @override
  String get securityRuleUnknownNumbers => 'Numeri sconosciuti';

  @override
  String get securityRuleUnknownNumbersDesc =>
      'Blocca tutte le chiamate non identificate';

  @override
  String get securityRuleSpam => 'Telemarketing';

  @override
  String get securityRuleSpamDesc => 'Rilevamento IA chiamate commerciali';

  @override
  String get securityRuleBlacklist => 'Lista nera personale';

  @override
  String securityRuleBlacklistDesc(int count) {
    return '$count numeri';
  }

  @override
  String get securityRuleForeign => 'Numeri esteri';

  @override
  String get securityRuleForeignDesc => 'Prefissi internazionali';

  @override
  String get securityRuleWhitelist => 'Lista bianca familiare';

  @override
  String securityRuleWhitelistDesc(int count) {
    return '$count contatti sempre consentiti';
  }

  @override
  String get securitySectionRecentBlocked => 'ULTIME CHIAMATE BLOCCATE';

  @override
  String get securitySeeAll => 'Vedi tutto';

  @override
  String get familyScreenTitle => 'Famiglia e Controllo Parentale';

  @override
  String get familySectionChildren => 'I MIEI FIGLI';

  @override
  String familyChildAge(String name, int age) {
    return '$name, $age anni';
  }

  @override
  String get familyStatusAtSchool => 'A scuola';

  @override
  String get familyStatusAtHome => 'A casa';

  @override
  String familyScoreLabel(int value) {
    return 'Punteggio $value';
  }

  @override
  String familyChildDetailsToast(String name) {
    return 'Dettagli di $name disponibili nello Sprint 2';
  }

  @override
  String get familySectionLocation => 'POSIZIONE IN TEMPO REALE';

  @override
  String get familyMapPlaceholderTitle => 'Mappa interattiva in arrivo';

  @override
  String get familyMapPlaceholderSubtitle => 'Google Maps — Sprint 2';

  @override
  String get familySectionZones => 'ZONE SICURE';

  @override
  String get familyZoneHome => 'Casa';

  @override
  String get familyZoneHomeDesc => 'Raggio 250m · Attiva 24h/24';

  @override
  String get familyZoneSchool => 'École Jules Ferry';

  @override
  String get familyZoneSchoolDesc => 'Raggio 100m · Lun-Ven 8-17';

  @override
  String get familyZoneStadium => 'Stadio municipale';

  @override
  String get familyZoneStadiumDesc => 'Raggio 150m · Mer-Sab pomeriggi';

  @override
  String get familySectionLimits => 'LIMITI GIORNALIERI';

  @override
  String get familyLimitScreen => 'Tempo schermo oggi';

  @override
  String get familyLimitDistance => 'Distanza da casa';

  @override
  String get fitnessScreenTitle => 'Fitness e Prestazioni';

  @override
  String get fitnessSectionToday => 'OGGI';

  @override
  String get fitnessSteps => 'Passi';

  @override
  String fitnessStepsGoal(int goal) {
    return '/ $goal obj.';
  }

  @override
  String get fitnessCalories => 'Calorie';

  @override
  String get fitnessCaloriesUnit => 'kcal';

  @override
  String get fitnessDistance => 'Distanza';

  @override
  String get fitnessDistanceUnit => 'km';

  @override
  String get fitnessHeartRate => 'BPM medio';

  @override
  String get fitnessHeartRateUnit => 'bpm';

  @override
  String get fitnessSectionWeekly => 'ATTIVITÀ SETTIMANALE';

  @override
  String get fitnessWeekdayMon => 'L';

  @override
  String get fitnessWeekdayTue => 'M';

  @override
  String get fitnessWeekdayWed => 'M';

  @override
  String get fitnessWeekdayThu => 'G';

  @override
  String get fitnessWeekdayFri => 'V';

  @override
  String get fitnessWeekdaySat => 'S';

  @override
  String get fitnessWeekdaySun => 'D';

  @override
  String get fitnessSectionRecords => 'I MIEI RECORD';

  @override
  String get fitnessRecordLongestWalk => 'Camminata più lunga';

  @override
  String get fitnessRecordLongestWalkDesc => '12.5 km · 2 settimane fa';

  @override
  String get fitnessRecordMostSteps => 'Più passi in 1 giorno';

  @override
  String get fitnessRecordMostStepsDesc => '14 832 passi · 1 mese fa';

  @override
  String get fitnessRecordFastestRun => 'Corsa più veloce';

  @override
  String get fitnessRecordFastestRunDesc => '5km in 28 min · 3 giorni fa';

  @override
  String get fitnessSectionSessions => 'ULTIME SESSIONI';

  @override
  String get fitnessSessionWalk => 'Camminata';

  @override
  String get fitnessSessionWalkDesc => '35min · 3.2km · ieri 18:12';

  @override
  String get fitnessSessionRun => 'Corsa';

  @override
  String get fitnessSessionRunDesc => '28min · 5km · 3 giorni fa';

  @override
  String get fitnessSessionBike => 'Ciclismo';

  @override
  String get fitnessSessionBikeDesc => '1h12 · 18km · 5 giorni fa';

  @override
  String get agendaScreenTitle => 'Agenda e Pianificazione';

  @override
  String get agendaDateToday => 'Oggi';

  @override
  String get agendaNavigationToast => 'Navigazione giornaliera in arrivo';

  @override
  String get agendaSectionModes => 'MODALITÀ DEL GIORNO';

  @override
  String get agendaModeFocus => 'Concentrazione';

  @override
  String get agendaModeFocusDesc => 'Notifiche limitate';

  @override
  String get agendaModeSleep => 'Sonno';

  @override
  String get agendaModeSleepDesc => 'Programmato 22h-7h';

  @override
  String get agendaSectionEvents => 'I MIEI EVENTI DI OGGI';

  @override
  String get agendaEventMeeting => 'Riunione team prodotto';

  @override
  String get agendaEventMeetingTime => '14:00–15:00 · Ufficio';

  @override
  String agendaEventMeetingDetail(int count) {
    return '$count partecipanti';
  }

  @override
  String get agendaEventDinner => 'Cena con i genitori';

  @override
  String get agendaEventDinnerTime => '19:30–21:00 · A casa';

  @override
  String get agendaEventDinnerDetail => 'Casa';

  @override
  String get agendaEventYoga => 'Lezione di yoga';

  @override
  String get agendaEventYogaTime => '18:00–19:00';

  @override
  String get agendaEventYogaDetail => 'Studio Mahalo';

  @override
  String get agendaCreateButton => 'Nuovo evento';

  @override
  String get agendaCreateToast => 'Creazione eventi disponibile nello Sprint 4';

  @override
  String get authWelcomeTitle => 'Benvenuto su Harmony';

  @override
  String get authCreatePinTitle => 'Crea il tuo PIN';

  @override
  String get authChoosePin => 'Scegli un codice a 4 cifre';

  @override
  String get authConfirmPinTitle => 'Conferma il tuo PIN';

  @override
  String get authReenterPin => 'Inserisci nuovamente il PIN';

  @override
  String get authEnterPin => 'Inserisci il tuo PIN';

  @override
  String get authPinMismatch => 'I codici non corrispondono';

  @override
  String get authIncorrectCode => 'Codice errato';

  @override
  String authAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativi rimanenti',
      one: '1 tentativo rimanente',
    );
    return '$_temp0';
  }

  @override
  String get authBiometricSetupTitle => 'Attivare la biometria?';

  @override
  String get authBiometricSetupDesc =>
      'Sblocca Harmony con Face ID o la tua impronta digitale.';

  @override
  String get authBiometricEnable => 'Attiva';

  @override
  String get authBiometricLater => 'Più tardi';

  @override
  String get authBiometricSkip => 'Salta';

  @override
  String get emptyStateComingSoon => 'Prossimamente';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsLanguage => 'Lingua';

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
  String get settingsTheme => 'Aspetto';

  @override
  String get settingsThemeSystem => 'Automatico';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get moduleContactsTitle => 'Contatti';

  @override
  String get moduleContactsSubtitle => 'Gestione contatti';

  @override
  String moduleContactsBadge(int count) {
    return '$count contatti';
  }

  @override
  String get contactsScreenTitle => 'Contatti';

  @override
  String get contactsSectionWhitelist => 'LISTA BIANCA';

  @override
  String get contactsSectionBlacklist => 'LISTA NERA';

  @override
  String get contactsAddContact => 'Aggiungi un contatto';

  @override
  String get contactsWhitelistBadge => 'consentito';

  @override
  String get contactsBlacklistBadge => 'bloccato';

  @override
  String get contactsEmpty => 'Nessun contatto';

  @override
  String get contactsRemove => 'Rimuovi';

  @override
  String get contactsPermissionTitle => 'Accesso ai contatti richiesto';

  @override
  String get contactsPermissionSubtitle =>
      'Harmony ha bisogno del tuo permesso per visualizzare la tua rubrica.';

  @override
  String get contactsPermissionCta => 'Consenti l\'accesso ai contatti';

  @override
  String get blacklistPickFromContacts => 'Scegli dai miei contatti';

  @override
  String get voicemailScreenTitle => 'Segreteria telefonica';

  @override
  String voicemailNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi messaggi',
      one: '1 nuovo messaggio',
      zero: 'Nessun nuovo messaggio',
    );
    return '$_temp0';
  }

  @override
  String voicemailTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messaggi in totale',
      one: '1 messaggio in totale',
    );
    return '$_temp0';
  }

  @override
  String get voicemailPushInfo => 'Simulazione push attivata';

  @override
  String get voicemailMarkRead => 'Segna come letto';

  @override
  String get voicemailDelete => 'Elimina';

  @override
  String get voicemailCallBack => 'Richiama';

  @override
  String get voicemailUrgent => 'Urgente';

  @override
  String get voicemailNewMessageToastTitle => 'Nuovo messaggio vocale';

  @override
  String voicemailNewMessageToastBody(String name) {
    return 'Messaggio da $name';
  }

  @override
  String get voicemailViewButton => 'Vedi';

  @override
  String get voicemailTranscriptionLabel => 'Trascrizione';

  @override
  String get voicemailExpandHint => 'Vedi trascrizione';

  @override
  String get voicemailMockNote =>
      'Trascrizioni simulate — STT reale nello Sprint 5';

  @override
  String get voicemailPlay => 'Ascolta';

  @override
  String get callScreeningEnableTitle => 'Attiva protezione';

  @override
  String get callScreeningEnableDescription =>
      'Per bloccare le chiamate indesiderate, Harmony deve essere la tua app di filtraggio predefinita';

  @override
  String get callScreeningEnableButton => 'Attiva';

  @override
  String get callScreeningActiveStatus => 'Protezione attiva';

  @override
  String get callLogScreenTitle => 'Registro blocchi';

  @override
  String get callLogFilterToday => 'Oggi';

  @override
  String get callLogFilterWeek => 'Questa settimana';

  @override
  String get callLogFilterAll => 'Tutto';

  @override
  String get callLogEmptyState => 'Nessuna chiamata bloccata';

  @override
  String get callLogClearAllButton => 'Cancella tutto';

  @override
  String get iosFilteringTitle => 'Filtro iOS';

  @override
  String get iosFilteringInstructions =>
      'Per attivare il blocco delle chiamate su iOS, attiva l\'estensione nelle Impostazioni.';

  @override
  String get iosFilteringStep1 =>
      'Apri Impostazioni → Telefono → Blocco e identificazione chiamate';

  @override
  String get iosFilteringStep2 => 'Attiva Harmony nell\'elenco';

  @override
  String get iosFilteringOpenSettingsButton => 'Apri impostazioni';

  @override
  String get outgoingCallAlertTitle =>
      'Chiamata potenzialmente a tariffa speciale';

  @override
  String outgoingCallAlertEstimatedCost(String cost) {
    return 'Costo stimato: $cost €/min';
  }

  @override
  String get outgoingCallAlertCancel => 'Annulla';

  @override
  String get outgoingCallAlertContinueButton => 'Continua chiamata';

  @override
  String get outgoingCallAlertDontAskAgain =>
      'Non chiedere più per questo numero';

  @override
  String get filterModeOff => 'Disattivato';

  @override
  String get filterModeNight => 'Notte';

  @override
  String get filterModeWork => 'Lavoro';

  @override
  String get filterModeFocus => 'Focus';

  @override
  String get filterModeWeekend => 'Weekend';

  @override
  String get filterModeEmergency => 'Emergenza';

  @override
  String get filterModeActivate => 'Attiva';

  @override
  String get filterModeConfigure => 'Configura';

  @override
  String get filterModeCurrentActive => 'Modalità attiva';

  @override
  String get blacklistScreenTitle => 'Lista nera';

  @override
  String get blacklistSearchHint => 'Cerca numero o etichetta...';

  @override
  String get blacklistEmptyTitle => 'Nessun numero bloccato';

  @override
  String get blacklistAddTitle => 'Aggiungi numero';

  @override
  String get blacklistEditTitle => 'Modifica voce';

  @override
  String get blacklistPhoneLabel => 'Numero di telefono';

  @override
  String get blacklistPhoneHint => '+33 6 12 34 56 78';

  @override
  String get blacklistLabelHint => 'Etichetta (opzionale)';

  @override
  String get blacklistReasonLabel => 'Motivo del blocco';

  @override
  String get blacklistSaveButton => 'Salva';

  @override
  String get blacklistReasonSpam => 'Spam';

  @override
  String get blacklistReasonTelemarketing => 'Telemarketing';

  @override
  String get blacklistReasonHarassment => 'Molestia';

  @override
  String get blacklistReasonOther => 'Altro';

  @override
  String get familyChildrenSection => 'I MIEI FIGLI';

  @override
  String get familyMapSection => 'LOCALIZZAZIONE IN TEMPO REALE';

  @override
  String get familyZonesSection => 'ZONE SICURE';

  @override
  String get familyAddZoneFAB => 'Aggiungi zona';

  @override
  String get childDetailTitle => 'Dettaglio bambino';

  @override
  String childAtZone(String name) {
    return 'A: $name';
  }

  @override
  String get childInTransit => 'In transito';

  @override
  String childSecurityScore(int value) {
    return 'Punteggio $value';
  }

  @override
  String get zoneEditorAddTitle => 'Nuova zona';

  @override
  String get zoneEditorEditTitle => 'Modifica zona';

  @override
  String get zoneFieldName => 'Nome della zona';

  @override
  String get zoneFieldRadius => 'Raggio';

  @override
  String get zoneFieldIcon => 'Icona';

  @override
  String get zoneIconHome => 'Casa';

  @override
  String get zoneIconSchool => 'Scuola';

  @override
  String get zoneIconSport => 'Sport';

  @override
  String get zoneIconOther => 'Altro';

  @override
  String get sosButtonLabel => 'SOS';

  @override
  String get sosHoldHint => 'Tieni premuto 3 secondi per attivare';

  @override
  String get sosActiveTitle => 'SOS ATTIVO';

  @override
  String get sosActiveCountdown => 'Chiamata in';

  @override
  String get sosActiveCancel => 'Annulla SOS';

  @override
  String get sosCancelConfirm => 'Sei al sicuro?';

  @override
  String get permissionLocationTitle => 'Posizione richiesta';

  @override
  String get permissionLocationBody =>
      'Harmony ha bisogno della tua posizione per monitorare le zone';

  @override
  String get permissionLocationGrant => 'Consenti';

  @override
  String get agendaNoEvents => 'Nessun evento';

  @override
  String get agendaTasksShortcut => 'I miei compiti';

  @override
  String get agendaGoogleShortcut => 'Google Calendar';

  @override
  String get agendaEventDetailTitle => 'Dettagli';

  @override
  String get agendaEventEdit => 'Modifica';

  @override
  String get agendaEventImportant => 'Segna importante';

  @override
  String get agendaEventDelete => 'Elimina';

  @override
  String get agendaEventDeleteConfirm => 'Eliminare questo evento?';

  @override
  String get agendaEventDeleteConfirmYes => 'Elimina';

  @override
  String get agendaEventDeleteConfirmNo => 'Annulla';

  @override
  String get agendaEventLocation => 'Luogo';

  @override
  String get agendaEventReminder => 'Promemoria';

  @override
  String agendaEventReminderMinutes(int n) {
    return '$n min prima';
  }

  @override
  String get agendaEventRecurrence => 'Ricorrenza';

  @override
  String get agendaEditorNewTitle => 'Nuovo evento';

  @override
  String get agendaEditorEditTitle => 'Modifica evento';

  @override
  String get agendaEditorSave => 'Salva';

  @override
  String get agendaEditorFieldTitle => 'Titolo';

  @override
  String get agendaEditorFieldDescription => 'Descrizione (opzionale)';

  @override
  String get agendaEditorFieldLocation => 'Luogo (opzionale)';

  @override
  String get agendaEditorFieldStart => 'Inizio';

  @override
  String get agendaEditorFieldEnd => 'Fine';

  @override
  String get agendaEditorFieldReminder => 'Promemoria';

  @override
  String get agendaEditorFieldCategory => 'Categoria';

  @override
  String get agendaEditorMarkImportant => 'Segna come importante';

  @override
  String get agendaEditorValidationTitle => 'Titolo obbligatorio';

  @override
  String get agendaTasksTitle => 'I miei Compiti';

  @override
  String get agendaTasksQuadrantDoFirst => 'Urgente & Importante';

  @override
  String get agendaTasksQuadrantSchedule => 'Importante, non urgente';

  @override
  String get agendaTasksQuadrantDelegate => 'Urgente, non importante';

  @override
  String get agendaTasksQuadrantDelete => 'Né urgente, né importante';

  @override
  String get agendaTasksEmpty => 'Nessun compito';

  @override
  String get agendaTasksAdd => 'Nuovo compito';

  @override
  String get agendaGoogleTitle => 'Google Calendar';

  @override
  String get agendaGoogleConnectButton => 'Collega Google Calendar';

  @override
  String get agendaGoogleConnectedAs => 'Connesso come';

  @override
  String get agendaGoogleDisconnect => 'Disconnetti';

  @override
  String get agendaGoogleSync => 'Sincronizza';

  @override
  String get agendaGoogleSyncing => 'Sincronizzazione...';

  @override
  String get agendaGoogleLastSync => 'Ultima sincronizzazione';

  @override
  String get agendaGoogleNotConnected => 'Non connesso';

  @override
  String get agendaCategorySport => 'Sport';

  @override
  String get agendaCategoryMedical => 'Medico';

  @override
  String get agendaCategoryProfessional => 'Professionale';

  @override
  String get agendaCategorySchool => 'Scuola';

  @override
  String get agendaCategoryLeisure => 'Svago';

  @override
  String get agendaCategoryOther => 'Altro';

  @override
  String get messagesModuleTitle => 'Messaggi';

  @override
  String get messagesModuleSubtitle => 'WhatsApp · Signal · SMS';

  @override
  String get messagesModuleBadge => 'attivo';

  @override
  String get messagesScreenTitle => 'Messaggi & SMS';

  @override
  String get messagesRefreshTooltip => 'Aggiorna messaggi';

  @override
  String get messagesListenerEnabledTitle => 'Accesso alle notifiche attivo';

  @override
  String get messagesListenerEnabledSubtitle =>
      'WhatsApp, Signal e Telegram sono monitorati';

  @override
  String get messagesListenerDisabledTitle =>
      'Accesso alle notifiche richiesto';

  @override
  String get messagesListenerDisabledSubtitle =>
      'Attiva l\'accesso per catturare WhatsApp, Signal e Telegram';

  @override
  String get messagesListenerEnableCta => 'Attiva accesso';

  @override
  String get messagesSectionRules => 'REGOLE DI FILTRO';

  @override
  String get messagesSectionRecent => 'MESSAGGI RECENTI';

  @override
  String get messagesStatTotal => 'Ricevuti';

  @override
  String get messagesStatBlocked => 'Bloccati';

  @override
  String get messagesStatRules => 'Regole';

  @override
  String get messagesEmptyState =>
      'Nessun messaggio catturato.\nAttiva l\'accesso alle notifiche\npoi invia un SMS o un messaggio WhatsApp.';

  @override
  String get messagesIosLimitation =>
      'iOS: WhatsApp e Signal non possono essere intercettati da Harmony a causa del sandboxing Apple. Solo gli SMS sono filtrabili. Usa Screen Time per limitare WhatsApp su iOS.';

  @override
  String get messagesPermissionRequiredTitle => 'Autorizzazione SMS richiesta';

  @override
  String get messagesPermissionRequiredSubtitle =>
      'Attiva l\'accesso agli SMS per visualizzare i messaggi in Harmony';

  @override
  String get messagesPermissionAllowCta => 'Consenti';

  @override
  String get messagesPermissionDeniedSnack =>
      'Autorizzazione SMS negata. Puoi attivarla nelle impostazioni dell\'app.';

  @override
  String get messageBlockedBadge => 'Bloccato';

  @override
  String get messageRuleNewTitle => 'Nuova regola';

  @override
  String get messageRuleEditTitle => 'Modifica regola';

  @override
  String get messageRuleLabelType => 'Tipo di regola';

  @override
  String get messageRuleLabelContact => 'Numero o nome';

  @override
  String get messageRuleLabelKeyword => 'Parola chiave';

  @override
  String get messageRuleHintKeyword => 'spam, pub, promo...';

  @override
  String get messageRulePickContacts => 'Scegli dai contatti';

  @override
  String get messageRuleScheduleInfo =>
      'Fascia oraria: la regola si applica tra queste ore';

  @override
  String get messageRuleScheduleLabel => 'Fascia (es. 22-7)';

  @override
  String get messageRuleLabelAction => 'Azione';

  @override
  String get messageRuleLabelSources => 'Fonti';

  @override
  String get messageRuleSourcesAll => 'Lascia vuoto per tutte le fonti';

  @override
  String get messageRuleValidationEmpty => 'Inserisci un valore';

  @override
  String get messageRuleAddButton => 'Aggiungi regola';

  @override
  String get messageRuleEditButton => 'Salva';

  @override
  String get messageRuleScheduleDisplay => '(fascia oraria)';

  @override
  String get fitnessPermissionTitle => 'Accesso all\'attività richiesto';

  @override
  String get fitnessPermissionSubtitle =>
      'Harmony ha bisogno del permesso per contare i tuoi passi e monitorare l\'attività';

  @override
  String get fitnessPermissionAllowCta => 'Consenti accesso';

  @override
  String get fitnessGoalTitle => 'OBIETTIVO GIORNALIERO';

  @override
  String fitnessGoalSteps(int count) {
    return '$count passi / giorno';
  }

  @override
  String get fitnessStartWorkout => 'Inizia sessione';

  @override
  String get fitnessStopWorkout => 'Ferma';

  @override
  String get fitnessWorkoutRunning => 'Sessione in corso';

  @override
  String get fitnessActiveMinutes => 'Min. attivi';

  @override
  String get fitnessWorkoutTypeWalk => 'Camminata';

  @override
  String get fitnessWorkoutTypeRun => 'Corsa';

  @override
  String get fitnessWorkoutTypeCycle => 'Ciclismo';

  @override
  String get childSettingsTitle => 'Impostazioni del bambino';

  @override
  String get sosContactsTitle => 'Contatti SOS';

  @override
  String get sosContactsEmpty => 'Nessun contatto SOS';

  @override
  String get sosContactsAdd => 'Aggiungi un contatto';

  @override
  String get subscriptionPaywallTitle => 'Harmony Premium';

  @override
  String get subscriptionPaywallSubtitle => 'Sblocca tutte le funzionalità';

  @override
  String get subscriptionCtaStart => 'Inizia ora';

  @override
  String get subscriptionRestorePurchases => 'Ripristina acquisti';

  @override
  String get subscriptionPeriodMonthly => 'Mensile';

  @override
  String get subscriptionPeriodYearly => 'Annuale  −20%';

  @override
  String get subscriptionPeriodLifetime => 'una volta';

  @override
  String subscriptionTrialNote(int days) {
    return 'Prova gratuita di $days giorni — cancella in qualsiasi momento';
  }

  @override
  String get subscriptionStatusTitle => 'Il mio abbonamento';

  @override
  String get subscriptionStatusFree => 'Gratuito';

  @override
  String get subscriptionStatusActive => 'Attivo';

  @override
  String get subscriptionStatusTrial => 'Prova gratuita';

  @override
  String get subscriptionStatusExpired => 'Scaduto';

  @override
  String get subscriptionUpgradeCta => 'Vedi piani';

  @override
  String get subscriptionManage => 'Gestisci abbonamento';

  @override
  String get subscriptionManageSubtitle =>
      'Modifica o annulla tramite App Store / Google Play';

  @override
  String get subscriptionWillNotRenew =>
      'Il tuo abbonamento non verrà rinnovato.';

  @override
  String get subscriptionUpgradeTitle => 'Passa a Premium';

  @override
  String get subscriptionUpgradeSubtitle =>
      'Sblocca la lista nera illimitata, profili bambini e monitoraggio fitness avanzato.';

  @override
  String get moduleMeditationTitle => 'Meditazione';

  @override
  String get moduleMeditationSubtitle => 'Sessioni guidate';

  @override
  String get moduleMeditationBadge => 'Nuovo';

  @override
  String get splashTagline => 'Il tuo santuario digitale';

  @override
  String get splashCtaButton => 'Entra in Harmony';

  @override
  String get messageDetailTypeSms => 'SMS';

  @override
  String get messageDetailTypeWhatsapp => 'WhatsApp';

  @override
  String get messageDetailTypeSignal => 'Signal';

  @override
  String get messageDetailTypeTelegram => 'Telegram';

  @override
  String get messageDetailMarkRead => 'Segna come letto';

  @override
  String get messageDetailBlockContact => 'Blocca questo contatto';

  @override
  String get greetingMorning => 'Buongiorno 🌅';

  @override
  String get greetingAfternoon => 'Buon pomeriggio ☀';

  @override
  String get greetingEvening => 'Buonasera 🌙';

  @override
  String get greetingNight => 'Buona notte 🌟';

  @override
  String welcomeStatsFiltered(int count) {
    return '$count messaggi filtrati oggi';
  }

  @override
  String welcomeStatsSteps(int current, int goal) {
    return '$current / $goal passi';
  }

  @override
  String welcomeStatsEvents(int count) {
    return '$count eventi oggi';
  }
}
