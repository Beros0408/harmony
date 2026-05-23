// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Harmony';

  @override
  String get dashboardTitle => 'Harmony';

  @override
  String get dashboardWelcomeWave => 'Bem-vindo 👋';

  @override
  String get dashboardAllServicesActive => 'Todos os serviços ativos';

  @override
  String get dashboardSectionModules => 'OS MEUS MÓDULOS';

  @override
  String get moduleSecurityTitle => 'Segurança';

  @override
  String get moduleSecuritySubtitle => 'Filtragem ativa';

  @override
  String get moduleSecurityBadge => 'ativo';

  @override
  String get moduleFamilyTitle => 'Família';

  @override
  String get moduleFamilySubtitle => 'Controlo parental';

  @override
  String moduleFamilyBadgeProfiles(int count) {
    return '$count perfis';
  }

  @override
  String get moduleFitnessTitle => 'Fitness';

  @override
  String moduleFitnessSubtitle(int current, int goal) {
    return '$current / $goal passos';
  }

  @override
  String get moduleFitnessBadge => 'em curso';

  @override
  String get moduleAgendaTitle => 'Agenda';

  @override
  String moduleAgendaSubtitle(int count) {
    return '$count eventos';
  }

  @override
  String get moduleAgendaBadge => 'hoje';

  @override
  String get navBack => 'Voltar';

  @override
  String get navBackToDashboard => 'Voltar ao painel';

  @override
  String get securityScreenTitle => 'Segurança e Filtragem';

  @override
  String get securityStatsBlocked => 'Bloqueados';

  @override
  String get securityStatsRules => 'Regras';

  @override
  String get securityStatsPrecision => 'Precisão';

  @override
  String get securitySectionActiveMode => 'MODO ATIVO';

  @override
  String get securityModeNormal => 'Modo Normal';

  @override
  String get securityModeFocus => 'Modo Foco';

  @override
  String get securityModeNight => 'Modo Noite';

  @override
  String get securitySectionRules => 'REGRAS DE FILTRAGEM';

  @override
  String get securityRuleUnknownNumbers => 'Números desconhecidos';

  @override
  String get securityRuleUnknownNumbersDesc =>
      'Bloquear todas as chamadas não identificadas';

  @override
  String get securityRuleSpam => 'Telemarketing';

  @override
  String get securityRuleSpamDesc => 'Deteção IA de chamadas comerciais';

  @override
  String get securityRuleBlacklist => 'Lista negra pessoal';

  @override
  String securityRuleBlacklistDesc(int count) {
    return '$count números';
  }

  @override
  String get securityRuleForeign => 'Números estrangeiros';

  @override
  String get securityRuleForeignDesc => 'Indicativos internacionais';

  @override
  String get securityRuleWhitelist => 'Lista branca familiar';

  @override
  String securityRuleWhitelistDesc(int count) {
    return '$count contactos sempre permitidos';
  }

  @override
  String get securitySectionRecentBlocked => 'ÚLTIMAS CHAMADAS BLOQUEADAS';

  @override
  String get securitySeeAll => 'Ver tudo';

  @override
  String get familyScreenTitle => 'Família e Controlo Parental';

  @override
  String get familySectionChildren => 'OS MEUS FILHOS';

  @override
  String familyChildAge(String name, int age) {
    return '$name, $age anos';
  }

  @override
  String get familyStatusAtSchool => 'Na escola';

  @override
  String get familyStatusAtHome => 'Em casa';

  @override
  String familyScoreLabel(int value) {
    return 'Pontuação $value';
  }

  @override
  String familyChildDetailsToast(String name) {
    return 'Detalhes de $name disponíveis no Sprint 2';
  }

  @override
  String get familySectionLocation => 'LOCALIZAÇÃO EM TEMPO REAL';

  @override
  String get familyMapPlaceholderTitle => 'Mapa interativo em breve';

  @override
  String get familyMapPlaceholderSubtitle => 'Google Maps — Sprint 2';

  @override
  String get familySectionZones => 'ZONAS SEGURAS';

  @override
  String get familyZoneHome => 'Casa';

  @override
  String get familyZoneHomeDesc => 'Raio 250m · Ativa 24h/dia';

  @override
  String get familyZoneSchool => 'École Jules Ferry';

  @override
  String get familyZoneSchoolDesc => 'Raio 100m · Seg-Sex 8h-17h';

  @override
  String get familyZoneStadium => 'Estádio municipal';

  @override
  String get familyZoneStadiumDesc => 'Raio 150m · Qua-Sáb tardes';

  @override
  String get familySectionLimits => 'LIMITES DIÁRIOS';

  @override
  String get familyLimitScreen => 'Tempo de ecrã hoje';

  @override
  String get familyLimitDistance => 'Distância de casa';

  @override
  String get fitnessScreenTitle => 'Fitness e Desempenho';

  @override
  String get fitnessSectionToday => 'HOJE';

  @override
  String get fitnessSteps => 'Passos';

  @override
  String fitnessStepsGoal(int goal) {
    return '/ $goal obj.';
  }

  @override
  String get fitnessCalories => 'Calorias';

  @override
  String get fitnessCaloriesUnit => 'kcal';

  @override
  String get fitnessDistance => 'Distância';

  @override
  String get fitnessDistanceUnit => 'km';

  @override
  String get fitnessHeartRate => 'BPM médio';

  @override
  String get fitnessHeartRateUnit => 'bpm';

  @override
  String get fitnessSectionWeekly => 'ATIVIDADE SEMANAL';

  @override
  String get fitnessWeekdayMon => 'S';

  @override
  String get fitnessWeekdayTue => 'T';

  @override
  String get fitnessWeekdayWed => 'Q';

  @override
  String get fitnessWeekdayThu => 'Q';

  @override
  String get fitnessWeekdayFri => 'S';

  @override
  String get fitnessWeekdaySat => 'S';

  @override
  String get fitnessWeekdaySun => 'D';

  @override
  String get fitnessSectionRecords => 'OS MEUS RECORDES';

  @override
  String get fitnessRecordLongestWalk => 'Caminhada mais longa';

  @override
  String get fitnessRecordLongestWalkDesc => '12.5 km · há 2 semanas';

  @override
  String get fitnessRecordMostSteps => 'Mais passos num dia';

  @override
  String get fitnessRecordMostStepsDesc => '14 832 passos · há 1 mês';

  @override
  String get fitnessRecordFastestRun => 'Corrida mais rápida';

  @override
  String get fitnessRecordFastestRunDesc => '5km em 28 min · há 3 dias';

  @override
  String get fitnessSectionSessions => 'ÚLTIMAS SESSÕES';

  @override
  String get fitnessSessionWalk => 'Caminhada';

  @override
  String get fitnessSessionWalkDesc => '35min · 3.2km · ontem 18h12';

  @override
  String get fitnessSessionRun => 'Corrida';

  @override
  String get fitnessSessionRunDesc => '28min · 5km · há 3 dias';

  @override
  String get fitnessSessionBike => 'Ciclismo';

  @override
  String get fitnessSessionBikeDesc => '1h12 · 18km · há 5 dias';

  @override
  String get agendaScreenTitle => 'Agenda e Planeamento';

  @override
  String get agendaDateToday => 'Hoje';

  @override
  String get agendaNavigationToast => 'Navegação por dia em breve';

  @override
  String get agendaSectionModes => 'MODOS DO DIA';

  @override
  String get agendaModeFocus => 'Concentração';

  @override
  String get agendaModeFocusDesc => 'Notificações limitadas';

  @override
  String get agendaModeSleep => 'Sono';

  @override
  String get agendaModeSleepDesc => 'Programado 22h-7h';

  @override
  String get agendaSectionEvents => 'OS MEUS EVENTOS DE HOJE';

  @override
  String get agendaEventMeeting => 'Reunião equipa de produto';

  @override
  String get agendaEventMeetingTime => '14h00–15h00 · Escritório';

  @override
  String agendaEventMeetingDetail(int count) {
    return '$count participantes';
  }

  @override
  String get agendaEventDinner => 'Jantar com os pais';

  @override
  String get agendaEventDinnerTime => '19h30–21h00 · Em casa';

  @override
  String get agendaEventDinnerDetail => 'Casa';

  @override
  String get agendaEventYoga => 'Aula de yoga';

  @override
  String get agendaEventYogaTime => '18h00–19h00';

  @override
  String get agendaEventYogaDetail => 'Studio Mahalo';

  @override
  String get agendaCreateButton => 'Novo evento';

  @override
  String get agendaCreateToast => 'Criação de evento disponível no Sprint 4';

  @override
  String get authWelcomeTitle => 'Bem-vindo ao Harmony';

  @override
  String get authCreatePinTitle => 'Criar o seu PIN';

  @override
  String get authChoosePin => 'Escolha um código de 4 dígitos';

  @override
  String get authConfirmPinTitle => 'Confirmar o seu PIN';

  @override
  String get authReenterPin => 'Introduza novamente o PIN';

  @override
  String get authEnterPin => 'Introduza o seu PIN';

  @override
  String get authPinMismatch => 'Os códigos não coincidem';

  @override
  String get authIncorrectCode => 'Código incorreto';

  @override
  String authAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativas restantes',
      one: '1 tentativa restante',
    );
    return '$_temp0';
  }

  @override
  String get authBiometricSetupTitle => 'Ativar biometria?';

  @override
  String get authBiometricSetupDesc =>
      'Desbloqueie o Harmony com Face ID ou a sua impressão digital.';

  @override
  String get authBiometricEnable => 'Ativar';

  @override
  String get authBiometricLater => 'Mais tarde';

  @override
  String get authBiometricSkip => 'Ignorar';

  @override
  String get emptyStateComingSoon => 'Em breve';

  @override
  String get settingsTitle => 'Definições';

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
}
