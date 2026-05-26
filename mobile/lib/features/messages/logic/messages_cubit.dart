import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../data/models/captured_message.dart';
import '../data/models/message_rule.dart';
import '../domain/i_messages_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  MessagesLoaded({
    required this.messages,
    required this.rules,
    required this.listenerEnabled,
  });

  final List<CapturedMessage> messages;
  final List<MessageRule> rules;

  /// Indique si le NotificationListenerService est actif.
  final bool listenerEnabled;

  int get blockedCount => messages.where((m) => m.isBlocked).length;
  int get totalCount => messages.length;
}

class MessagesListenerDisabled extends MessagesState {}

class MessagesError extends MessagesState {
  MessagesError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({required IMessagesRepository repository})
      : _repository = repository,
        super(MessagesInitial());

  final IMessagesRepository _repository;
  static const _uuid = Uuid();

  Future<void> load() async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesCubit.load() start — state: ${state.runtimeType}');
    emit(MessagesLoading());
    try {
      final listenerEnabled = await _repository.isListenerEnabled();
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] MessagesCubit.load() listenerEnabled=$listenerEnabled');

      final messages = await _repository.getAllMessages();
      final rules = await _repository.getRules();

      // ignore: avoid_print
      print('[MESSAGES-DEBUG] MessagesCubit.load() → ${messages.length} messages, ${rules.length} règles');

      emit(MessagesLoaded(
        messages: messages,
        rules: rules,
        listenerEnabled: listenerEnabled,
      ));
    } catch (e, st) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] MessagesCubit.load() EXCEPTION: $e\n$st');
      emit(MessagesError(e.toString()));
    }
  }

  Future<void> requestListenerAccess() async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesCubit.requestListenerAccess()');
    try {
      await _repository.requestListenerAccess();
      // Recharger après retour de l'écran paramètres
      await load();
    } catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] requestListenerAccess EXCEPTION: $e');
      emit(MessagesError(e.toString()));
    }
  }

  Future<void> addRule(MessageRule rule) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesCubit.addRule(${rule.ruleType.name} "${rule.value}")');
    try {
      final ruleWithId = rule.id.isEmpty
          ? rule.copyWith(id: _uuid.v4())
          : rule;
      await _repository.addRule(ruleWithId);
      await load();
    } catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] addRule EXCEPTION: $e');
      emit(MessagesError(e.toString()));
    }
  }

  Future<void> updateRule(MessageRule rule) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesCubit.updateRule(${rule.id})');
    try {
      await _repository.updateRule(rule);
      await load();
    } catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] updateRule EXCEPTION: $e');
      emit(MessagesError(e.toString()));
    }
  }

  Future<void> deleteRule(String id) async {
    // ignore: avoid_print
    print('[MESSAGES-DEBUG] MessagesCubit.deleteRule($id)');
    try {
      await _repository.deleteRule(id);
      await load();
    } catch (e) {
      // ignore: avoid_print
      print('[MESSAGES-DEBUG] deleteRule EXCEPTION: $e');
      emit(MessagesError(e.toString()));
    }
  }
}
