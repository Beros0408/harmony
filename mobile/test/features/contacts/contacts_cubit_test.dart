import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/contacts/data/models/native_contact.dart';
import 'package:harmony/features/contacts/data/repositories/mock_contacts_repository.dart';
import 'package:harmony/features/contacts/logic/contacts_cubit.dart';

void main() {
  group('ContactsCubit — load', () {
    blocTest<ContactsCubit, ContactsState>(
      'émet Loading puis Loaded quand la permission est accordée',
      build: () => ContactsCubit(
        repository: MockContactsRepository(permissionGranted: true),
      ),
      act: (c) => c.load(),
      expect: () => [
        isA<ContactsLoading>(),
        isA<ContactsLoaded>().having(
          (s) => (s as ContactsLoaded).contacts,
          'contacts',
          isNotEmpty,
        ),
      ],
    );

    blocTest<ContactsCubit, ContactsState>(
      'émet Loading puis PermissionDenied quand la permission est refusée',
      build: () => ContactsCubit(
        repository: MockContactsRepository(permissionGranted: false),
      ),
      act: (c) => c.load(),
      expect: () => [
        isA<ContactsLoading>(),
        isA<ContactsPermissionDenied>(),
      ],
    );
  });

  group('ContactsCubit — requestPermission', () {
    blocTest<ContactsCubit, ContactsState>(
      'accorde la permission et charge les contacts',
      build: () => ContactsCubit(
        repository: MockContactsRepository(permissionGranted: false),
      ),
      act: (c) => c.requestPermission(),
      expect: () => [
        isA<ContactsLoading>(),
        isA<ContactsLoaded>().having(
          (s) => (s as ContactsLoaded).contacts,
          'contacts',
          isNotEmpty,
        ),
      ],
    );
  });

  group('ContactsCubit — search', () {
    blocTest<ContactsCubit, ContactsState>(
      'filtre les contacts par nom',
      build: () => ContactsCubit(
        repository: MockContactsRepository(permissionGranted: true),
      ),
      act: (c) async {
        await c.load();
        await c.search('Alice');
      },
      expect: () => [
        isA<ContactsLoading>(),
        isA<ContactsLoaded>().having(
          (s) => (s as ContactsLoaded).contacts.length,
          'length',
          greaterThan(0),
        ),
        isA<ContactsLoaded>().having(
          (s) => (s as ContactsLoaded).contacts,
          'contacts',
          predicate<List<NativeContact>>(
            (list) => list.every((c) => c.displayName.contains('Alice')),
            'contient uniquement Alice',
          ),
        ),
      ],
    );
  });
}
