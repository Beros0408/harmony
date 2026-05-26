import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/native_contact.dart';
import '../domain/i_contacts_repository.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  ContactsLoaded(this.contacts, {this.query = ''});
  final List<NativeContact> contacts;
  final String query;
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
    emit(ContactsLoading());
    try {
      final granted = await _repository.hasPermission();
      if (!granted) {
        emit(ContactsPermissionDenied());
        return;
      }
      final contacts = await _repository.fetchAll();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> requestPermission() async {
    emit(ContactsLoading());
    try {
      final granted = await _repository.requestPermission();
      if (!granted) {
        emit(ContactsPermissionDenied());
        return;
      }
      final contacts = await _repository.fetchAll();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> search(String query) async {
    if (state is! ContactsLoaded) return;
    try {
      final contacts = await _repository.fetchAll(query: query);
      emit(ContactsLoaded(contacts, query: query));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }
}
