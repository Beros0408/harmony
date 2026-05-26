import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/native_contact.dart';
import '../domain/i_contacts_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  ContactsLoaded(this.contacts, {this.query = '', this.rawCount = 0});
  final List<NativeContact> contacts;
  final String query;
  /// How many raw contacts FlutterContacts returned (before any filter).
  /// Used by the empty-state debug card when contacts == 0.
  final int rawCount;
}

class ContactsPermissionDenied extends ContactsState {}

class ContactsError extends ContactsState {
  ContactsError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit({required IContactsRepository repository})
      : _repository = repository,
        super(ContactsInitial());

  final IContactsRepository _repository;

  Future<void> load() async {
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] ContactsCubit.load() start — current state: ${state.runtimeType}');
    emit(ContactsLoading());
    try {
      final granted = await _repository.hasPermission();
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsCubit.load() hasPermission=$granted');
      if (!granted) {
        // ignore: avoid_print
        print('[CONTACTS-DEBUG] ContactsCubit.load() → emitting ContactsPermissionDenied');
        emit(ContactsPermissionDenied());
        return;
      }
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsCubit.load() calling fetchAll()...');
      final contacts = await _repository.fetchAll();
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsCubit.load() fetchAll() returned ${contacts.length} contacts → emitting ContactsLoaded');
      emit(ContactsLoaded(contacts, rawCount: contacts.length));
    } catch (e, st) {
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsCubit.load() EXCEPTION: $e\n$st');
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> requestPermission() async {
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] ContactsCubit.requestPermission() start');
    emit(ContactsLoading());
    try {
      final granted = await _repository.requestPermission();
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsCubit.requestPermission() granted=$granted');
      if (!granted) {
        emit(ContactsPermissionDenied());
        return;
      }
      final contacts = await _repository.fetchAll();
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsCubit.requestPermission() → ${contacts.length} contacts loaded');
      emit(ContactsLoaded(contacts, rawCount: contacts.length));
    } catch (e, st) {
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsCubit.requestPermission() EXCEPTION: $e\n$st');
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> search(String query) async {
    if (state is! ContactsLoaded) return;
    final prevRaw = (state as ContactsLoaded).rawCount;
    try {
      final contacts = await _repository.fetchAll(query: query);
      emit(ContactsLoaded(contacts, query: query, rawCount: prevRaw));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }
}
