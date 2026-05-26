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
    final raw = await _service.fetchAll();
    final contacts = raw
        .where((c) => c.phones.isNotEmpty)
        .map(
          (c) => NativeContact(
            id: c.id,
            displayName: c.displayName,
            phone: c.phones.first.number,
          ),
        )
        .toList();

    if (query.isEmpty) return contacts;
    final q = query.toLowerCase();
    return contacts
        .where(
          (c) =>
              c.displayName.toLowerCase().contains(q) ||
              (c.phone?.contains(q) ?? false),
        )
        .toList();
  }
}
