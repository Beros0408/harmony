import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around flutter_contacts + permission_handler.
/// All platform-level contact access goes through here so repositories
/// can be tested with a mock without touching the OS.
class ContactsService {
  ContactsService._();

  static final ContactsService instance = ContactsService._();

  /// Returns true if the contacts permission has already been granted,
  /// without triggering a system prompt.
  Future<bool> hasPermission() async {
    final status = await Permission.contacts.status;
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] hasPermission() status=$status isGranted=${status.isGranted}');
    return status.isGranted;
  }

  /// Shows the system permission dialog. Returns true if granted.
  Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] requestPermission() status=$status isGranted=${status.isGranted}');
    return status.isGranted;
  }

  /// Fetches all device contacts (no phone filter — let repository decide).
  Future<List<Contact>> fetchAll() async {
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] ContactsService.fetchAll() calling FlutterContacts.getContacts...');
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        sorted: true,
      );
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsService.fetchAll() returned ${contacts.length} raw contacts');
      for (final c in contacts) {
        // ignore: avoid_print
        print('[CONTACTS-DEBUG]   id=${c.id} name="${c.displayName}" phones=${c.phones.length}');
      }
      return contacts;
    } catch (e, st) {
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsService.fetchAll() EXCEPTION: $e\n$st');
      rethrow;
    }
  }
}
