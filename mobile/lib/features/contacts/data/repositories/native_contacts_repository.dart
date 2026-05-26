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
    print('[CONTACTS-DEBUG] NativeContactsRepository.fetchAll(query="$query") — essai MethodChannel natif');

    // Stratégie 1 — MethodChannel Kotlin : lit TOUS les contacts (y compris account_type=NULL)
    try {
      final contacts = await _service.fetchAllRaw(query: query);
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] NativeContactsRepository: MethodChannel OK → ${contacts.length} contacts');
      return contacts;
    } catch (e) {
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] NativeContactsRepository: MethodChannel FAILED ($e) → fallback flutter_contacts');
    }

    // Stratégie 2 (fallback) — flutter_contacts
    // Ignore les contacts avec account_type=NULL mais reste fonctionnel sur
    // les téléphones avec un compte Google configuré.
    try {
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] NativeContactsRepository: démarrage fallback flutter_contacts...');
      final raw = await _service.fetchAll();
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] NativeContactsRepository: flutter_contacts returned ${raw.length} raw contacts');

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

      if (query.isEmpty) return contacts;
      final q = query.toLowerCase();
      return contacts
          .where(
            (c) =>
                c.displayName.toLowerCase().contains(q) ||
                (c.phone?.contains(q) ?? false),
          )
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] NativeContactsRepository: flutter_contacts FAILED ($e) → liste vide');
      return [];
    }
  }
}
