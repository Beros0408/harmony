// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Harmony';

  @override
  String get dashboardTitle => 'Harmony';

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
  String get authWelcomeTitle => 'Bienvenido a Harmony';

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
      'Desbloquea Harmony con Face ID o tu huella dactilar.';

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
}
