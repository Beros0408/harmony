// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'KimiaCare';

  @override
  String get dashboardTitle => 'KimiaCare';

  @override
  String get dashboardWelcomeWave => 'Bienvenido 👋';

  @override
  String get dashboardAllServicesActive => 'Todos los servicios activos';

  @override
  String get dashboardSectionModules => 'MIS MÓDULOS';

  @override
  String get moduleSecurityTitle => 'Seguridad';

  @override
  String get moduleSecuritySubtitle => 'Filtrado activo';

  @override
  String get moduleSecurityBadge => 'activo';

  @override
  String get moduleFamilyTitle => 'Familia';

  @override
  String get moduleFamilySubtitle => 'Control parental';

  @override
  String moduleFamilyBadgeProfiles(int count) {
    return '$count perfiles';
  }

  @override
  String get moduleFitnessTitle => 'Fitness';

  @override
  String moduleFitnessSubtitle(int current, int goal) {
    return '$current / $goal pasos';
  }

  @override
  String get moduleFitnessBadge => 'en curso';

  @override
  String get moduleAgendaTitle => 'Agenda';

  @override
  String moduleAgendaSubtitle(int count) {
    return '$count eventos';
  }

  @override
  String get moduleAgendaBadge => 'hoy';

  @override
  String get navBack => 'Volver';

  @override
  String get navBackToDashboard => 'Volver al panel';

  @override
  String get securityScreenTitle => 'Seguridad y Filtrado';

  @override
  String get securityStatsBlocked => 'Bloqueados';

  @override
  String get securityStatsRules => 'Reglas';

  @override
  String get securityStatsPrecision => 'Precisión';

  @override
  String get securitySectionActiveMode => 'MODO ACTIVO';

  @override
  String get securityModeNormal => 'Modo Normal';

  @override
  String get securityModeFocus => 'Modo Concentración';

  @override
  String get securityModeNight => 'Modo Noche';

  @override
  String get securitySectionRules => 'REGLAS DE FILTRADO';

  @override
  String get securityRuleUnknownNumbers => 'Números desconocidos';

  @override
  String get securityRuleUnknownNumbersDesc =>
      'Bloquear todas las llamadas no identificadas';

  @override
  String get securityRuleSpam => 'Telemarketing';

  @override
  String get securityRuleSpamDesc => 'Detección IA de llamadas comerciales';

  @override
  String get securityRuleBlacklist => 'Lista negra personal';

  @override
  String securityRuleBlacklistDesc(int count) {
    return '$count números';
  }

  @override
  String get securityRuleForeign => 'Números extranjeros';

  @override
  String get securityRuleForeignDesc => 'Prefijos internacionales';

  @override
  String get securityRuleWhitelist => 'Lista blanca familiar';

  @override
  String securityRuleWhitelistDesc(int count) {
    return '$count contactos siempre permitidos';
  }

  @override
  String get securitySectionRecentBlocked => 'ÚLTIMAS LLAMADAS BLOQUEADAS';

  @override
  String get securitySeeAll => 'Ver todo';

  @override
  String get familyScreenTitle => 'Familia y Control Parental';

  @override
  String get familySectionChildren => 'MIS HIJOS';

  @override
  String familyChildAge(String name, int age) {
    return '$name, $age años';
  }

  @override
  String get familyStatusAtSchool => 'En el colegio';

  @override
  String get familyStatusAtHome => 'En casa';

  @override
  String familyScoreLabel(int value) {
    return 'Puntuación $value';
  }

  @override
  String familyChildDetailsToast(String name) {
    return 'Detalles de $name disponibles en Sprint 2';
  }

  @override
  String get familySectionLocation => 'LOCALIZACIÓN EN TIEMPO REAL';

  @override
  String get familyMapPlaceholderTitle => 'Mapa interactivo próximamente';

  @override
  String get familyMapPlaceholderSubtitle => 'Google Maps — Sprint 2';

  @override
  String get familySectionZones => 'ZONAS SEGURAS';

  @override
  String get familyZoneHome => 'Casa';

  @override
  String get familyZoneHomeDesc => 'Radio 250m · Activa 24h/día';

  @override
  String get familyZoneSchool => 'École Jules Ferry';

  @override
  String get familyZoneSchoolDesc => 'Radio 100m · Lun-Vie 8h-17h';

  @override
  String get familyZoneStadium => 'Estadio municipal';

  @override
  String get familyZoneStadiumDesc => 'Radio 150m · Mié-Sáb tardes';

  @override
  String get familySectionLimits => 'LÍMITES DIARIOS';

  @override
  String get familyLimitScreen => 'Tiempo de pantalla hoy';

  @override
  String get familyLimitDistance => 'Distancia desde casa';

  @override
  String get fitnessScreenTitle => 'Fitness y Rendimiento';

  @override
  String get fitnessSectionToday => 'HOY';

  @override
  String get fitnessSteps => 'Pasos';

  @override
  String fitnessStepsGoal(int goal) {
    return '/ $goal obj.';
  }

  @override
  String get fitnessCalories => 'Calorías';

  @override
  String get fitnessCaloriesUnit => 'kcal';

  @override
  String get fitnessDistance => 'Distancia';

  @override
  String get fitnessDistanceUnit => 'km';

  @override
  String get fitnessHeartRate => 'BPM medio';

  @override
  String get fitnessHeartRateUnit => 'bpm';

  @override
  String get fitnessSectionWeekly => 'ACTIVIDAD SEMANAL';

  @override
  String get fitnessWeekdayMon => 'L';

  @override
  String get fitnessWeekdayTue => 'M';

  @override
  String get fitnessWeekdayWed => 'X';

  @override
  String get fitnessWeekdayThu => 'J';

  @override
  String get fitnessWeekdayFri => 'V';

  @override
  String get fitnessWeekdaySat => 'S';

  @override
  String get fitnessWeekdaySun => 'D';

  @override
  String get fitnessSectionRecords => 'MIS RÉCORDS';

  @override
  String get fitnessRecordLongestWalk => 'Caminata más larga';

  @override
  String get fitnessRecordLongestWalkDesc => '12.5 km · hace 2 semanas';

  @override
  String get fitnessRecordMostSteps => 'Más pasos en 1 día';

  @override
  String get fitnessRecordMostStepsDesc => '14 832 pasos · hace 1 mes';

  @override
  String get fitnessRecordFastestRun => 'Carrera más rápida';

  @override
  String get fitnessRecordFastestRunDesc => '5km en 28 min · hace 3 días';

  @override
  String get fitnessSectionSessions => 'ÚLTIMAS SESIONES';

  @override
  String get fitnessSessionWalk => 'Caminata';

  @override
  String get fitnessSessionWalkDesc => '35min · 3.2km · ayer 18h12';

  @override
  String get fitnessSessionRun => 'Carrera';

  @override
  String get fitnessSessionRunDesc => '28min · 5km · hace 3 días';

  @override
  String get fitnessSessionBike => 'Ciclismo';

  @override
  String get fitnessSessionBikeDesc => '1h12 · 18km · hace 5 días';

  @override
  String get agendaScreenTitle => 'Agenda y Planificación';

  @override
  String get agendaDateToday => 'Hoy';

  @override
  String get agendaNavigationToast => 'Navegación por día próximamente';

  @override
  String get agendaSectionModes => 'MODOS DEL DÍA';

  @override
  String get agendaModeFocus => 'Concentración';

  @override
  String get agendaModeFocusDesc => 'Notificaciones limitadas';

  @override
  String get agendaModeSleep => 'Sueño';

  @override
  String get agendaModeSleepDesc => 'Programado 22h-7h';

  @override
  String get agendaSectionEvents => 'MIS EVENTOS DE HOY';

  @override
  String get agendaEventMeeting => 'Reunión equipo de producto';

  @override
  String get agendaEventMeetingTime => '14h00–15h00 · Oficina';

  @override
  String agendaEventMeetingDetail(int count) {
    return '$count participantes';
  }

  @override
  String get agendaEventDinner => 'Cena con los padres';

  @override
  String get agendaEventDinnerTime => '19h30–21h00 · En casa';

  @override
  String get agendaEventDinnerDetail => 'Casa';

  @override
  String get agendaEventYoga => 'Clase de yoga';

  @override
  String get agendaEventYogaTime => '18h00–19h00';

  @override
  String get agendaEventYogaDetail => 'Studio Mahalo';

  @override
  String get agendaCreateButton => 'Nuevo evento';

  @override
  String get agendaCreateToast => 'Creación de evento disponible en Sprint 4';

  @override
  String get authWelcomeTitle => 'Bienvenido a KimiaCare';

  @override
  String get authCreatePinTitle => 'Crea tu código PIN';

  @override
  String get authChoosePin => 'Elige un código de 4 dígitos';

  @override
  String get authConfirmPinTitle => 'Confirma tu código PIN';

  @override
  String get authReenterPin => 'Vuelve a introducir el código PIN';

  @override
  String get authEnterPin => 'Introduce tu código PIN';

  @override
  String get authPinMismatch => 'Los códigos no coinciden';

  @override
  String get authIncorrectCode => 'Código incorrecto';

  @override
  String authAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intentos restantes',
      one: '1 intento restante',
    );
    return '$_temp0';
  }

  @override
  String get authBiometricSetupTitle => '¿Activar biometría?';

  @override
  String get authBiometricSetupDesc =>
      'Desbloquea KimiaCare con Face ID o tu huella dactilar.';

  @override
  String get authBiometricEnable => 'Activar';

  @override
  String get authBiometricLater => 'Más tarde';

  @override
  String get authBiometricSkip => 'Omitir';

  @override
  String get emptyStateComingSoon => 'Próximamente';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsLanguage => 'Idioma';

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
  String get settingsTheme => 'Apariencia';

  @override
  String get settingsThemeSystem => 'Automático';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get moduleContactsTitle => 'Contactos';

  @override
  String get moduleContactsSubtitle => 'Gestión de contactos';

  @override
  String moduleContactsBadge(int count) {
    return '$count contactos';
  }

  @override
  String get contactsScreenTitle => 'Contactos';

  @override
  String get contactsSectionWhitelist => 'LISTA BLANCA';

  @override
  String get contactsSectionBlacklist => 'LISTA NEGRA';

  @override
  String get contactsAddContact => 'Añadir un contacto';

  @override
  String get contactsWhitelistBadge => 'permitido';

  @override
  String get contactsBlacklistBadge => 'bloqueado';

  @override
  String get contactsEmpty => 'Sin contactos';

  @override
  String get contactsRemove => 'Eliminar';

  @override
  String get contactsPermissionTitle => 'Acceso a contactos requerido';

  @override
  String get contactsPermissionSubtitle =>
      'KimiaCare necesita tu permiso para mostrar tu agenda.';

  @override
  String get contactsPermissionCta => 'Permitir acceso a contactos';

  @override
  String get blacklistPickFromContacts => 'Elegir de mis contactos';

  @override
  String get voicemailScreenTitle => 'Buzón de voz';

  @override
  String voicemailNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes nuevos',
      one: '1 mensaje nuevo',
      zero: 'Sin mensajes nuevos',
    );
    return '$_temp0';
  }

  @override
  String voicemailTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensajes en total',
      one: '1 mensaje en total',
    );
    return '$_temp0';
  }

  @override
  String get voicemailPushInfo => 'Simulación de push activada';

  @override
  String get voicemailMarkRead => 'Marcar como leído';

  @override
  String get voicemailDelete => 'Eliminar';

  @override
  String get voicemailCallBack => 'Devolver llamada';

  @override
  String get voicemailUrgent => 'Urgente';

  @override
  String get voicemailNewMessageToastTitle => 'Nuevo mensaje de voz';

  @override
  String voicemailNewMessageToastBody(String name) {
    return 'Mensaje de $name';
  }

  @override
  String get voicemailViewButton => 'Ver';

  @override
  String get voicemailTranscriptionLabel => 'Transcripción';

  @override
  String get voicemailExpandHint => 'Ver transcripción';

  @override
  String get voicemailMockNote =>
      'Transcripciones simuladas — STT real en Sprint 5';

  @override
  String get voicemailPlay => 'Escuchar';

  @override
  String get callScreeningEnableTitle => 'Activar protección';

  @override
  String get callScreeningEnableDescription =>
      'Para bloquear llamadas no deseadas, KimiaCare debe ser tu app de filtrado por defecto';

  @override
  String get callScreeningEnableButton => 'Activar';

  @override
  String get callScreeningActiveStatus => 'Protección activa';

  @override
  String get callLogScreenTitle => 'Registro de bloqueos';

  @override
  String get callLogFilterToday => 'Hoy';

  @override
  String get callLogFilterWeek => 'Esta semana';

  @override
  String get callLogFilterAll => 'Todo';

  @override
  String get callLogEmptyState => 'No hay llamadas bloqueadas';

  @override
  String get callLogClearAllButton => 'Borrar todo';

  @override
  String get iosFilteringTitle => 'Filtrado iOS';

  @override
  String get iosFilteringInstructions =>
      'Para activar el bloqueo de llamadas en iOS, active la extensión en Ajustes.';

  @override
  String get iosFilteringStep1 =>
      'Abra Ajustes → Teléfono → Bloqueo e identificación de llamadas';

  @override
  String get iosFilteringStep2 => 'Active KimiaCare en la lista';

  @override
  String get iosFilteringOpenSettingsButton => 'Abrir ajustes';

  @override
  String get outgoingCallAlertTitle =>
      'Llamada potencialmente de tarifa especial';

  @override
  String outgoingCallAlertEstimatedCost(String cost) {
    return 'Coste estimado: $cost €/min';
  }

  @override
  String get outgoingCallAlertCancel => 'Cancelar';

  @override
  String get outgoingCallAlertContinueButton => 'Continuar llamada';

  @override
  String get outgoingCallAlertDontAskAgain =>
      'No preguntar de nuevo para este número';

  @override
  String get filterModeOff => 'Desactivado';

  @override
  String get filterModeNight => 'Noche';

  @override
  String get filterModeWork => 'Trabajo';

  @override
  String get filterModeFocus => 'Foco';

  @override
  String get filterModeWeekend => 'Fin de semana';

  @override
  String get filterModeEmergency => 'Emergencia';

  @override
  String get filterModeActivate => 'Activar';

  @override
  String get filterModeConfigure => 'Configurar';

  @override
  String get filterModeCurrentActive => 'Modo activo';

  @override
  String get blacklistScreenTitle => 'Lista negra';

  @override
  String get blacklistSearchHint => 'Buscar número o etiqueta...';

  @override
  String get blacklistEmptyTitle => 'Ningún número bloqueado';

  @override
  String get blacklistAddTitle => 'Añadir número';

  @override
  String get blacklistEditTitle => 'Editar entrada';

  @override
  String get blacklistPhoneLabel => 'Número de teléfono';

  @override
  String get blacklistPhoneHint => '+33 6 12 34 56 78';

  @override
  String get blacklistLabelHint => 'Etiqueta (opcional)';

  @override
  String get blacklistReasonLabel => 'Motivo de bloqueo';

  @override
  String get blacklistSaveButton => 'Guardar';

  @override
  String get blacklistReasonSpam => 'Spam';

  @override
  String get blacklistReasonTelemarketing => 'Telemarketing';

  @override
  String get blacklistReasonHarassment => 'Acoso';

  @override
  String get blacklistReasonOther => 'Otro';

  @override
  String get familyChildrenSection => 'MIS HIJOS';

  @override
  String get familyMapSection => 'LOCALIZACIÓN EN TIEMPO REAL';

  @override
  String get familyZonesSection => 'ZONAS SEGURAS';

  @override
  String get familyAddZoneFAB => 'Añadir zona';

  @override
  String get childDetailTitle => 'Detalle del niño';

  @override
  String childAtZone(String name) {
    return 'En: $name';
  }

  @override
  String get childInTransit => 'En movimiento';

  @override
  String childSecurityScore(int value) {
    return 'Puntuación $value';
  }

  @override
  String get zoneEditorAddTitle => 'Nueva zona';

  @override
  String get zoneEditorEditTitle => 'Editar zona';

  @override
  String get zoneFieldName => 'Nombre de la zona';

  @override
  String get zoneFieldRadius => 'Radio';

  @override
  String get zoneFieldIcon => 'Icono';

  @override
  String get zoneIconHome => 'Casa';

  @override
  String get zoneIconSchool => 'Escuela';

  @override
  String get zoneIconSport => 'Deporte';

  @override
  String get zoneIconOther => 'Otro';

  @override
  String get zoneMapTapHint => 'Toca el mapa para posicionar la zona';

  @override
  String get zoneFieldNameHint => 'Ej.: Colegio San José';

  @override
  String get zoneChildrenLabel => 'Hijos afectados';

  @override
  String get familyNoChildrenPaired => 'Ningún hijo vinculado por el momento';

  @override
  String get familyAddChildButton => 'Añadir un hijo';

  @override
  String get zoneScheduleAllDay => 'Todo el día';

  @override
  String get unlinkDialogTitle => 'Solicitud de desvinculación';

  @override
  String unlinkDialogBody(String childName) {
    return '$childName solicita retirar este dispositivo del control parental. ¿Aceptas?';
  }

  @override
  String get unlinkDialogReject => 'Rechazar';

  @override
  String get unlinkDialogApprove => 'Aprobar';

  @override
  String unlinkApprovedSnack(String childName) {
    return 'Desvinculación de $childName aprobada.';
  }

  @override
  String get unlinkApproveError => 'Error al aprobar. Inténtalo de nuevo.';

  @override
  String unlinkRejectedSnack(String childName) {
    return 'Solicitud de $childName rechazada.';
  }

  @override
  String get unlinkRejectError => 'Error al rechazar. Inténtalo de nuevo.';

  @override
  String get sosButtonLabel => 'SOS';

  @override
  String get sosHoldHint => 'Mantén 3 segundos para activar';

  @override
  String get sosActiveTitle => 'SOS ACTIVO';

  @override
  String get sosActiveCountdown => 'Llamando en';

  @override
  String get sosActiveCancel => 'Cancelar SOS';

  @override
  String get sosCancelConfirm => '¿Estás a salvo?';

  @override
  String get sosTriggerConfirmTitle => '¿Enviar una alerta SOS?';

  @override
  String get sosTriggerConfirmMessage =>
      'Tu padre o madre será alertado inmediatamente con tu posición.';

  @override
  String get sosTriggerConfirmCancel => 'Cancelar';

  @override
  String get sosTriggerConfirmSend => 'Enviar SOS';

  @override
  String get sosSentSuccess => 'SOS enviado, tu padre o madre ha sido alertado';

  @override
  String get sosSentError => 'No se puede enviar el SOS, comprueba tu conexión';

  @override
  String get sosSectionTitle => 'ALERTAS SOS';

  @override
  String get sosNoActive => 'Sin alerta SOS — todo va bien.';

  @override
  String get sosAcknowledge => 'Visto — Confirmar';

  @override
  String sosPosition(String lat, String lon) {
    return 'Posición: $lat, $lon';
  }

  @override
  String get sosViewOnMap => 'Ver en el mapa';

  @override
  String get sosLoadError => 'Imposible cargar las alertas SOS.';

  @override
  String get sosAckError => 'Imposible confirmar la alerta.';

  @override
  String get permissionLocationTitle => 'Ubicación requerida';

  @override
  String get permissionLocationBody =>
      'KimiaCare necesita tu ubicación para supervisar las zonas';

  @override
  String get permissionLocationGrant => 'Permitir';

  @override
  String get agendaNoEvents => 'Sin eventos';

  @override
  String get agendaTasksShortcut => 'Mis tareas';

  @override
  String get agendaGoogleShortcut => 'Google Calendar';

  @override
  String get agendaEventDetailTitle => 'Detalles';

  @override
  String get agendaEventEdit => 'Editar';

  @override
  String get agendaEventImportant => 'Marcar importante';

  @override
  String get agendaEventDelete => 'Eliminar';

  @override
  String get agendaEventDeleteConfirm => '¿Eliminar este evento?';

  @override
  String get agendaEventDeleteConfirmYes => 'Eliminar';

  @override
  String get agendaEventDeleteConfirmNo => 'Cancelar';

  @override
  String get agendaEventLocation => 'Lugar';

  @override
  String get agendaEventReminder => 'Recordatorio';

  @override
  String agendaEventReminderMinutes(int n) {
    return '$n min antes';
  }

  @override
  String get agendaEventRecurrence => 'Recurrencia';

  @override
  String get agendaEditorNewTitle => 'Nuevo evento';

  @override
  String get agendaEditorEditTitle => 'Editar evento';

  @override
  String get agendaEditorSave => 'Guardar';

  @override
  String get agendaEditorFieldTitle => 'Título';

  @override
  String get agendaEditorFieldDescription => 'Descripción (opcional)';

  @override
  String get agendaEditorFieldLocation => 'Lugar (opcional)';

  @override
  String get agendaEditorFieldStart => 'Inicio';

  @override
  String get agendaEditorFieldEnd => 'Fin';

  @override
  String get agendaEditorFieldReminder => 'Recordatorio';

  @override
  String get agendaEditorFieldCategory => 'Categoría';

  @override
  String get agendaEditorMarkImportant => 'Marcar como importante';

  @override
  String get agendaEditorValidationTitle => 'Título requerido';

  @override
  String get agendaTasksTitle => 'Mis Tareas';

  @override
  String get agendaTasksQuadrantDoFirst => 'Urgente e Importante';

  @override
  String get agendaTasksQuadrantSchedule => 'Importante, no urgente';

  @override
  String get agendaTasksQuadrantDelegate => 'Urgente, no importante';

  @override
  String get agendaTasksQuadrantDelete => 'Ni urgente, ni importante';

  @override
  String get agendaTasksEmpty => 'Sin tareas';

  @override
  String get agendaTasksAdd => 'Nueva tarea';

  @override
  String get agendaGoogleTitle => 'Google Calendar';

  @override
  String get agendaGoogleConnectButton => 'Conectar Google Calendar';

  @override
  String get agendaGoogleConnectedAs => 'Conectado como';

  @override
  String get agendaGoogleDisconnect => 'Desconectar';

  @override
  String get agendaGoogleSync => 'Sincronizar';

  @override
  String get agendaGoogleSyncing => 'Sincronizando...';

  @override
  String get agendaGoogleLastSync => 'Última sincronización';

  @override
  String get agendaGoogleNotConnected => 'No conectado';

  @override
  String get agendaCategorySport => 'Deporte';

  @override
  String get agendaCategoryMedical => 'Médico';

  @override
  String get agendaCategoryProfessional => 'Profesional';

  @override
  String get agendaCategorySchool => 'Escuela';

  @override
  String get agendaCategoryLeisure => 'Ocio';

  @override
  String get agendaCategoryOther => 'Otro';

  @override
  String get messagesModuleTitle => 'Mensajes';

  @override
  String get messagesModuleSubtitle => 'WhatsApp · Signal · SMS';

  @override
  String get messagesModuleBadge => 'activo';

  @override
  String get messagesScreenTitle => 'Mensajes & SMS';

  @override
  String get messagesRefreshTooltip => 'Actualizar mensajes';

  @override
  String get messagesListenerEnabledTitle => 'Acceso a notificaciones activo';

  @override
  String get messagesListenerEnabledSubtitle =>
      'WhatsApp, Signal y Telegram están siendo monitoreados';

  @override
  String get messagesListenerDisabledTitle =>
      'Acceso a notificaciones requerido';

  @override
  String get messagesListenerDisabledSubtitle =>
      'Activa el acceso para capturar WhatsApp, Signal y Telegram';

  @override
  String get messagesListenerEnableCta => 'Activar acceso';

  @override
  String get messagesSectionRules => 'REGLAS DE FILTRADO';

  @override
  String get messagesSectionRecent => 'MENSAJES RECIENTES';

  @override
  String get messagesStatTotal => 'Recibidos';

  @override
  String get messagesStatBlocked => 'Bloqueados';

  @override
  String get messagesStatRules => 'Reglas';

  @override
  String get messagesEmptyState =>
      'No se capturaron mensajes.\nActiva el acceso a notificaciones\ny luego envía un SMS o mensaje de WhatsApp.';

  @override
  String get messagesIosLimitation =>
      'iOS: WhatsApp y Signal no pueden ser interceptados por KimiaCare debido al sandboxing de Apple. Solo los SMS se pueden filtrar. Usa Screen Time para limitar WhatsApp en iOS.';

  @override
  String get messagesPermissionRequiredTitle => 'Permiso de SMS requerido';

  @override
  String get messagesPermissionRequiredSubtitle =>
      'Activa el acceso a SMS para ver los mensajes en KimiaCare';

  @override
  String get messagesPermissionAllowCta => 'Permitir';

  @override
  String get messagesPermissionDeniedSnack =>
      'Permiso de SMS denegado. Puedes activarlo en la configuración de la aplicación.';

  @override
  String get messageBlockedBadge => 'Bloqueado';

  @override
  String get messageRuleNewTitle => 'Nueva regla';

  @override
  String get messageRuleEditTitle => 'Editar regla';

  @override
  String get messageRuleLabelType => 'Tipo de regla';

  @override
  String get messageRuleLabelContact => 'Número o nombre';

  @override
  String get messageRuleLabelKeyword => 'Palabra clave';

  @override
  String get messageRuleHintKeyword => 'spam, pub, promo...';

  @override
  String get messageRulePickContacts => 'Elegir de mis contactos';

  @override
  String get messageRuleScheduleInfo =>
      'Franja horaria: la regla se aplica entre estas horas';

  @override
  String get messageRuleScheduleLabel => 'Franja (ej. 22-7)';

  @override
  String get messageRuleLabelAction => 'Acción';

  @override
  String get messageRuleLabelSources => 'Fuentes';

  @override
  String get messageRuleSourcesAll => 'Dejar vacío para todas las fuentes';

  @override
  String get messageRuleValidationEmpty => 'Introduce un valor';

  @override
  String get messageRuleAddButton => 'Añadir regla';

  @override
  String get messageRuleEditButton => 'Guardar';

  @override
  String get messageRuleScheduleDisplay => '(franja horaria)';

  @override
  String get fitnessPermissionTitle => 'Acceso a la actividad requerido';

  @override
  String get fitnessPermissionSubtitle =>
      'KimiaCare necesita permiso para contar tus pasos y registrar tu actividad';

  @override
  String get fitnessPermissionAllowCta => 'Permitir acceso';

  @override
  String get fitnessGoalTitle => 'OBJETIVO DIARIO';

  @override
  String fitnessGoalSteps(int count) {
    return '$count pasos / día';
  }

  @override
  String get fitnessStartWorkout => 'Iniciar sesión';

  @override
  String get fitnessStopWorkout => 'Detener';

  @override
  String get fitnessWorkoutRunning => 'Sesión en progreso';

  @override
  String get fitnessActiveMinutes => 'Min. activos';

  @override
  String get fitnessWorkoutTypeWalk => 'Caminar';

  @override
  String get fitnessWorkoutTypeRun => 'Correr';

  @override
  String get fitnessWorkoutTypeCycle => 'Ciclismo';

  @override
  String get childSettingsTitle => 'Configuración del niño';

  @override
  String get sosContactsTitle => 'Contactos SOS';

  @override
  String get sosContactsEmpty => 'Sin contactos SOS';

  @override
  String get sosContactsAdd => 'Añadir un contacto';

  @override
  String get sosContactsCall => 'Llamar';

  @override
  String get sosContactsSms => 'SMS';

  @override
  String get subscriptionPaywallTitle => 'KimiaCare Premium';

  @override
  String get subscriptionPaywallSubtitle => 'Desbloquea todas las funciones';

  @override
  String get subscriptionCtaStart => 'Empezar ahora';

  @override
  String get subscriptionRestorePurchases => 'Restaurar compras';

  @override
  String get subscriptionPeriodMonthly => 'Mensual';

  @override
  String get subscriptionPeriodYearly => 'Anual  −20%';

  @override
  String get subscriptionPeriodLifetime => 'una vez';

  @override
  String subscriptionTrialNote(int days) {
    return 'Prueba gratuita de $days días — cancela en cualquier momento';
  }

  @override
  String get subscriptionStatusTitle => 'Mi suscripción';

  @override
  String get subscriptionStatusFree => 'Gratis';

  @override
  String get subscriptionStatusActive => 'Activo';

  @override
  String get subscriptionStatusTrial => 'Prueba gratuita';

  @override
  String get subscriptionStatusExpired => 'Expirado';

  @override
  String get subscriptionUpgradeCta => 'Ver planes';

  @override
  String get subscriptionManage => 'Gestionar suscripción';

  @override
  String get subscriptionManageSubtitle =>
      'Modificar o cancelar en la App Store / Google Play';

  @override
  String get subscriptionWillNotRenew => 'Tu suscripción no se renovará.';

  @override
  String get subscriptionUpgradeTitle => 'Pasar a Premium';

  @override
  String get subscriptionUpgradeSubtitle =>
      'Desbloquea la lista negra ilimitada, perfiles infantiles y seguimiento avanzado de fitness.';

  @override
  String get moduleMeditationTitle => 'Meditación';

  @override
  String get moduleMeditationSubtitle => 'Sesiones guiadas';

  @override
  String get moduleMeditationBadge => 'Nuevo';

  @override
  String get splashTagline => 'Tu santuario digital';

  @override
  String get splashCtaButton => 'Entrar en KimiaCare';

  @override
  String get messageDetailTypeSms => 'SMS';

  @override
  String get messageDetailTypeWhatsapp => 'WhatsApp';

  @override
  String get messageDetailTypeSignal => 'Signal';

  @override
  String get messageDetailTypeTelegram => 'Telegram';

  @override
  String get messageDetailMarkRead => 'Marcar como leído';

  @override
  String get messageDetailBlockContact => 'Bloquear este contacto';

  @override
  String get callFilterRulesTitle => 'Filtrado de llamadas';

  @override
  String get callFilterRulesSubtitle =>
      'Gestionar números permitidos o bloqueados';

  @override
  String get callFilterModeBlacklist => 'Lista negra';

  @override
  String get callFilterModeWhitelist => 'Lista blanca';

  @override
  String get callFilterModeBlacklistDesc =>
      'Se permiten todas las llamadas excepto los números listados';

  @override
  String get callFilterModeWhitelistDesc =>
      'Solo los números listados pueden llamar';

  @override
  String get callFilterRulesEmpty => 'Sin números en la lista';

  @override
  String get callFilterRulesEmptyDesc =>
      'Añade números para bloquear o permitir según el modo activo';

  @override
  String get callFilterAddRule => 'Agregar un número';

  @override
  String get callFilterPhoneLabel => 'Número de teléfono';

  @override
  String get callFilterPhoneHint => '+34 612 345 678';

  @override
  String get callFilterLabelOptional => 'Etiqueta (opcional)';

  @override
  String get callFilterTypeBlacklist => 'Bloqueado';

  @override
  String get callFilterTypeWhitelist => 'Permitido';

  @override
  String get callFilterDeleteConfirm => '¿Eliminar esta regla?';

  @override
  String get callFilterDeleteContent => 'Este número se eliminará de la lista.';

  @override
  String get callFilterDuplicateError => 'Este número ya está en la lista';

  @override
  String get callFilterSaveError => 'Error al guardar la regla';

  @override
  String get callFilterLoadError => 'Error al cargar las reglas';

  @override
  String get callFilterDeleteError => 'Error al eliminar la regla';

  @override
  String get callFilterInfoBanner =>
      'Los números añadidos aquí se aplican automáticamente en el dispositivo del niño.';

  @override
  String get callFilterPhoneEmptyError => 'Por favor ingresa un número';

  @override
  String get blockedCallsLogTitle => 'LLAMADAS BLOQUEADAS';

  @override
  String get blockedCallsLogEmpty => 'No hay llamadas bloqueadas recientemente';

  @override
  String get blockedCallsLogLoadError =>
      'No se pueden cargar las llamadas bloqueadas.';

  @override
  String get blockedCallsLogBadgeBlacklist => 'Lista negra';

  @override
  String get blockedCallsLogBadgeWhitelist => 'Lista blanca';

  @override
  String get greetingMorning => 'Buenos días 🌅';

  @override
  String get greetingAfternoon => 'Buenas tardes ☀';

  @override
  String get greetingEvening => 'Buenas noches 🌙';

  @override
  String get greetingNight => 'Buena madrugada 🌟';

  @override
  String welcomeStatsFiltered(int count) {
    return '$count mensajes filtrados hoy';
  }

  @override
  String welcomeStatsSteps(int current, int goal) {
    return '$current / $goal pasos';
  }

  @override
  String welcomeStatsEvents(int count) {
    return '$count eventos hoy';
  }
}
