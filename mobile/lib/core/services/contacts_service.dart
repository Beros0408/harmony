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
    return status.isGranted;
  }

  /// Shows the system permission dialog. Returns true if granted.
  Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  /// Fetches all device contacts that have at least one phone number.
  /// Results are sorted alphabetically by display name.
  Future<List<Contact>> fetchAll() =>
      FlutterContacts.getContacts(withProperties: true, sorted: true);
}
