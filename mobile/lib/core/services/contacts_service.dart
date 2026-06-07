import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../features/contacts/data/models/native_contact.dart';

/// Thin wrapper around flutter_contacts + permission_handler +
/// le MethodChannel natif ContactsReaderPlugin (Sprint 5.2).
///
/// Hiérarchie d'appel dans NativeContactsRepository :
///   1. fetchAllRaw() → MethodChannel Kotlin (lit TOUS les contacts, y compris account_type=NULL)
///   2. fetchAll()    → flutter_contacts (fallback si MethodChannel indisponible)
class ContactsService {
  ContactsService._();

  static final ContactsService instance = ContactsService._();

  static const _channel = MethodChannel('com.kimiacare.app/contacts_reader');

  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<bool> hasPermission() async {
    final status = await Permission.contacts.status;
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] hasPermission() status=$status isGranted=${status.isGranted}');
    return status.isGranted;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.contacts.request();
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] requestPermission() status=$status isGranted=${status.isGranted}');
    return status.isGranted;
  }

  // ─── Lecture via MethodChannel natif (préféré) ────────────────────────────

  /// Query ContactsReaderPlugin.kt — lit TOUS les raw_contacts du device,
  /// y compris ceux avec account_type=NULL (cas des émulateurs et téléphones
  /// sans compte Google connecté). Retourne une liste de [NativeContact].
  Future<List<NativeContact>> fetchAllRaw({String query = ''}) async {
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] ContactsService.fetchAllRaw() → calling MethodChannel readAllContacts...');
    try {
      final dynamic result = await _channel.invokeMethod<dynamic>('readAllContacts');
      final raw = (result as List<dynamic>)
          .cast<Map<Object?, Object?>>();

      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsService.fetchAllRaw() MethodChannel returned ${raw.length} contacts');

      final contacts = raw.map((map) {
        final id = (map['id'] as String?) ?? '';
        final displayName = (map['displayName'] as String?) ?? '';
        final phones = (map['phones'] as List<dynamic>?)
                ?.cast<String>() ??
            const [];
        // ignore: avoid_print
        print('[CONTACTS-DEBUG]   native: id=$id name="$displayName" phones=${phones.length}');
        return NativeContact(
          id: id,
          displayName: displayName.isEmpty ? '(sans nom)' : displayName,
          phone: phones.isNotEmpty ? phones.first : null,
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
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsService.fetchAllRaw() PlatformException: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('[CONTACTS-DEBUG] ContactsService.fetchAllRaw() exception: $e');
      rethrow;
    }
  }

  // ─── Lecture via flutter_contacts (fallback) ──────────────────────────────

  /// Fallback — utilisé si fetchAllRaw() lance une exception.
  /// flutter_contacts 1.1.9 ignore les contacts sans account_type.
  Future<List<Contact>> fetchAll() async {
    // ignore: avoid_print
    print('[CONTACTS-DEBUG] ContactsService.fetchAll() (flutter_contacts fallback) calling getContacts...');
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
