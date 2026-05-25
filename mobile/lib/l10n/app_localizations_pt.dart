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

  @override
  String get settingsTheme => 'Aparência';

  @override
  String get settingsThemeSystem => 'Automático';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get moduleContactsTitle => 'Contactos';

  @override
  String get moduleContactsSubtitle => 'Gestão de contactos';

  @override
  String moduleContactsBadge(int count) {
    return '$count contactos';
  }

  @override
  String get contactsScreenTitle => 'Contactos';

  @override
  String get contactsSectionWhitelist => 'LISTA BRANCA';

  @override
  String get contactsSectionBlacklist => 'LISTA NEGRA';

  @override
  String get contactsAddContact => 'Adicionar um contacto';

  @override
  String get contactsWhitelistBadge => 'permitido';

  @override
  String get contactsBlacklistBadge => 'bloqueado';

  @override
  String get contactsEmpty => 'Sem contactos';

  @override
  String get contactsRemove => 'Remover';

  @override
  String get voicemailScreenTitle => 'Correio de voz';

  @override
  String voicemailNewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novas mensagens',
      one: '1 nova mensagem',
      zero: 'Nenhuma nova mensagem',
    );
    return '$_temp0';
  }

  @override
  String voicemailTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mensagens no total',
      one: '1 mensagem no total',
    );
    return '$_temp0';
  }

  @override
  String get voicemailPushInfo => 'Simulação de push ativada';

  @override
  String get voicemailMarkRead => 'Marcar como lido';

  @override
  String get voicemailDelete => 'Eliminar';

  @override
  String get voicemailCallBack => 'Ligar de volta';

  @override
  String get voicemailUrgent => 'Urgente';

  @override
  String get voicemailNewMessageToastTitle => 'Nova mensagem de voz';

  @override
  String voicemailNewMessageToastBody(String name) {
    return 'Mensagem de $name';
  }

  @override
  String get voicemailViewButton => 'Ver';

  @override
  String get voicemailTranscriptionLabel => 'Transcrição';

  @override
  String get voicemailExpandHint => 'Ver transcrição';

  @override
  String get voicemailMockNote =>
      'Transcrições simuladas — STT real no Sprint 5';

  @override
  String get voicemailPlay => 'Ouvir';

  @override
  String get callScreeningEnableTitle => 'Ativar proteção';

  @override
  String get callScreeningEnableDescription =>
      'Para bloquear chamadas indesejadas, o Harmony deve ser a sua app de filtragem predefinida';

  @override
  String get callScreeningEnableButton => 'Ativar';

  @override
  String get callScreeningActiveStatus => 'Proteção ativa';

  @override
  String get callLogScreenTitle => 'Registo de bloqueios';

  @override
  String get callLogFilterToday => 'Hoje';

  @override
  String get callLogFilterWeek => 'Esta semana';

  @override
  String get callLogFilterAll => 'Tudo';

  @override
  String get callLogEmptyState => 'Nenhuma chamada bloqueada';

  @override
  String get callLogClearAllButton => 'Limpar tudo';

  @override
  String get iosFilteringTitle => 'Filtragem iOS';

  @override
  String get iosFilteringInstructions =>
      'Para ativar o bloqueio de chamadas no iOS, ative a extensão nas Definições.';

  @override
  String get iosFilteringStep1 =>
      'Abra Definições → Telefone → Bloqueio e identificação de chamadas';

  @override
  String get iosFilteringStep2 => 'Ative o Harmony na lista';

  @override
  String get iosFilteringOpenSettingsButton => 'Abrir definições';

  @override
  String get outgoingCallAlertTitle => 'Chamada potencialmente tarifada';

  @override
  String outgoingCallAlertEstimatedCost(String cost) {
    return 'Custo estimado: $cost €/min';
  }

  @override
  String get outgoingCallAlertCancel => 'Cancelar';

  @override
  String get outgoingCallAlertContinueButton => 'Continuar chamada';

  @override
  String get outgoingCallAlertDontAskAgain =>
      'Não perguntar novamente para este número';

  @override
  String get filterModeOff => 'Desativado';

  @override
  String get filterModeNight => 'Noite';

  @override
  String get filterModeWork => 'Trabalho';

  @override
  String get filterModeFocus => 'Foco';

  @override
  String get filterModeWeekend => 'Fim de semana';

  @override
  String get filterModeEmergency => 'Emergência';

  @override
  String get filterModeActivate => 'Ativar';

  @override
  String get filterModeConfigure => 'Configurar';

  @override
  String get filterModeCurrentActive => 'Modo ativo';

  @override
  String get blacklistScreenTitle => 'Lista negra';

  @override
  String get blacklistSearchHint => 'Pesquisar número ou etiqueta...';

  @override
  String get blacklistEmptyTitle => 'Nenhum número bloqueado';

  @override
  String get blacklistAddTitle => 'Adicionar número';

  @override
  String get blacklistEditTitle => 'Editar entrada';

  @override
  String get blacklistPhoneLabel => 'Número de telefone';

  @override
  String get blacklistPhoneHint => '+33 6 12 34 56 78';

  @override
  String get blacklistLabelHint => 'Etiqueta (opcional)';

  @override
  String get blacklistReasonLabel => 'Motivo do bloqueio';

  @override
  String get blacklistSaveButton => 'Guardar';

  @override
  String get blacklistReasonSpam => 'Spam';

  @override
  String get blacklistReasonTelemarketing => 'Telemarketing';

  @override
  String get blacklistReasonHarassment => 'Assédio';

  @override
  String get blacklistReasonOther => 'Outro';

  @override
  String get familyChildrenSection => 'MEUS FILHOS';

  @override
  String get familyMapSection => 'LOCALIZAÇÃO EM TEMPO REAL';

  @override
  String get familyZonesSection => 'ZONAS SEGURAS';

  @override
  String get familyAddZoneFAB => 'Adicionar zona';

  @override
  String get childDetailTitle => 'Detalhe da criança';

  @override
  String childAtZone(String name) {
    return 'Em: $name';
  }

  @override
  String get childInTransit => 'Em trânsito';

  @override
  String childSecurityScore(int value) {
    return 'Pontuação $value';
  }

  @override
  String get zoneEditorAddTitle => 'Nova zona';

  @override
  String get zoneEditorEditTitle => 'Editar zona';

  @override
  String get zoneFieldName => 'Nome da zona';

  @override
  String get zoneFieldRadius => 'Raio';

  @override
  String get zoneFieldIcon => 'Ícone';

  @override
  String get zoneIconHome => 'Casa';

  @override
  String get zoneIconSchool => 'Escola';

  @override
  String get zoneIconSport => 'Esporte';

  @override
  String get zoneIconOther => 'Outro';

  @override
  String get sosButtonLabel => 'SOS';

  @override
  String get sosHoldHint => 'Segure 3 segundos para acionar';

  @override
  String get sosActiveTitle => 'SOS ATIVO';

  @override
  String get sosActiveCountdown => 'Ligando em';

  @override
  String get sosActiveCancel => 'Cancelar SOS';

  @override
  String get sosCancelConfirm => 'Você está seguro?';

  @override
  String get permissionLocationTitle => 'Localização necessária';

  @override
  String get permissionLocationBody =>
      'Harmony precisa da sua localização para monitorar as zonas';

  @override
  String get permissionLocationGrant => 'Permitir';

  @override
  String get agendaNoEvents => 'Nenhum evento';

  @override
  String get agendaTasksShortcut => 'Minhas tarefas';

  @override
  String get agendaGoogleShortcut => 'Google Agenda';

  @override
  String get agendaEventDetailTitle => 'Detalhes';

  @override
  String get agendaEventEdit => 'Editar';

  @override
  String get agendaEventImportant => 'Marcar importante';

  @override
  String get agendaEventDelete => 'Excluir';

  @override
  String get agendaEventDeleteConfirm => 'Excluir este evento?';

  @override
  String get agendaEventDeleteConfirmYes => 'Excluir';

  @override
  String get agendaEventDeleteConfirmNo => 'Cancelar';

  @override
  String get agendaEventLocation => 'Local';

  @override
  String get agendaEventReminder => 'Lembrete';

  @override
  String agendaEventReminderMinutes(int n) {
    return '$n min antes';
  }

  @override
  String get agendaEventRecurrence => 'Recorrência';

  @override
  String get agendaEditorNewTitle => 'Novo evento';

  @override
  String get agendaEditorEditTitle => 'Editar evento';

  @override
  String get agendaEditorSave => 'Salvar';

  @override
  String get agendaEditorFieldTitle => 'Título';

  @override
  String get agendaEditorFieldDescription => 'Descrição (opcional)';

  @override
  String get agendaEditorFieldLocation => 'Local (opcional)';

  @override
  String get agendaEditorFieldStart => 'Início';

  @override
  String get agendaEditorFieldEnd => 'Fim';

  @override
  String get agendaEditorFieldReminder => 'Lembrete';

  @override
  String get agendaEditorFieldCategory => 'Categoria';

  @override
  String get agendaEditorMarkImportant => 'Marcar como importante';

  @override
  String get agendaEditorValidationTitle => 'Título obrigatório';

  @override
  String get agendaTasksTitle => 'Minhas Tarefas';

  @override
  String get agendaTasksQuadrantDoFirst => 'Urgente & Importante';

  @override
  String get agendaTasksQuadrantSchedule => 'Importante, não urgente';

  @override
  String get agendaTasksQuadrantDelegate => 'Urgente, não importante';

  @override
  String get agendaTasksQuadrantDelete => 'Nem urgente, nem importante';

  @override
  String get agendaTasksEmpty => 'Nenhuma tarefa';

  @override
  String get agendaTasksAdd => 'Nova tarefa';

  @override
  String get agendaGoogleTitle => 'Google Agenda';

  @override
  String get agendaGoogleConnectButton => 'Conectar Google Agenda';

  @override
  String get agendaGoogleConnectedAs => 'Conectado como';

  @override
  String get agendaGoogleDisconnect => 'Desconectar';

  @override
  String get agendaGoogleSync => 'Sincronizar';

  @override
  String get agendaGoogleSyncing => 'Sincronizando...';

  @override
  String get agendaGoogleLastSync => 'Última sincronização';

  @override
  String get agendaGoogleNotConnected => 'Não conectado';

  @override
  String get agendaCategorySport => 'Esporte';

  @override
  String get agendaCategoryMedical => 'Médico';

  @override
  String get agendaCategoryProfessional => 'Profissional';

  @override
  String get agendaCategorySchool => 'Escola';

  @override
  String get agendaCategoryLeisure => 'Lazer';

  @override
  String get agendaCategoryOther => 'Outro';
}
