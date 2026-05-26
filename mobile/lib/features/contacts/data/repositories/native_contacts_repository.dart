import '../../../../core/services/contacts_service.dart';
import '../models/native_contact.dart';
import '../../domain/i_contacts_repository.dart';

class NativeContactsRepository implements IContactsRepository {
  NativeContactsRepository({ContactsService? service})
      : _service = service ?? ContactsService.instance;

  final ContactsService _service;

  static final NativeContactsRepository instance = NativeContactsRepository();

  @override
  Future<bool> hasPermission() => _service.hasPermission();

  @override
  Future<bool> requestPermission() => _service.requestPermission();

  @override
  Future<List<NativeContact>> fetchAll({String query = ''}) async {
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] NativeContactsRepository.fetchAll(query="$query") start');
    final raw = await _service.fetchAll();
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] NativeContactsRepository: received ${raw.length} raw contacts from service');

    // Phone filter relaxed (was `c.phones.isNotEmpty`) — include contacts
    // without phones so we can diagnose whether flutter_contacts is returning
    // contacts at all but without phone data attached.
    final contacts = raw.map((c) {
      final phone = c.phones.isNotEmpty ? c.phones.first.number : null;
      // ignore: avoid_print
      print('[CONTACTS-DEBUG]   mapping: "${c.displayName}" phones=${c.phones.length} firstPhone=$phone');
      return NativeContact(
        id: c.id,
        displayName: c.displayName.isEmpty ? '(sans nom)' : c.displayName,
        phone: phone,
      );
    }).toList();

    // ignore: avoid_print
    print('[CONTACTS-DEBUG] NativeContactsRepository: mapped ${contacts.length} NativeContacts (${contacts.where((c) => c.phone != null).length} with phone)');

    if (query.isEmpty) return contacts;
    final q = query.toLowerCase();
    final filtered = contacts
        .where(
          (c) =>
              c.displayName.toLowerCase().contains(q) ||
              (c.phone?.contains(q) ?? false),
        )
        .toList();
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] NativeContactsRepository: after query filter → ${filtered.length} contacts');
    return filtered;
  }
}
