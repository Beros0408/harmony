import '../models/native_contact.dart';
import '../../domain/i_contacts_repository.dart';

class MockContactsRepository implements IContactsRepository {
  MockContactsRepository({
    List<NativeContact>? contacts,
    bool permissionGranted = true,
  })  : _contacts = contacts ?? _defaults,
        _hasPermission = permissionGranted;

  final List<NativeContact> _contacts;
  bool _hasPermission;

  @override
  Future<bool> hasPermission() async => _hasPermission;

  @override
  Future<bool> requestPermission() async {
    _hasPermission = true;
    return true;
  }

  @override
  Future<List<NativeContact>> fetchAll({String query = ''}) async {
    if (!_hasPermission) return [];
    if (query.isEmpty) return List.of(_contacts);
    final q = query.toLowerCase();
    return _contacts
        .where(
          (c) =>
              c.displayName.toLowerCase().contains(q) ||
              (c.phone?.contains(q) ?? false),
        )
        .toList();
  }

  static const _defaults = [
    NativeContact(id: '1', displayName: 'Alice Dupont', phone: '+33612345678'),
    NativeContact(id: '2', displayName: 'Bob Martin', phone: '+33798765432'),
    NativeContact(id: '3', displayName: 'Marie Lefebvre', phone: '+33655443322'),
    NativeContact(id: '4', displayName: 'Jean-Paul Moreau', phone: '+33623456789'),
    NativeContact(id: '5', displayName: 'Sophie Lambert', phone: '+33712345678'),
  ];
}
