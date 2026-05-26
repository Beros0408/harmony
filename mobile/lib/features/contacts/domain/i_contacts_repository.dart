import '../data/models/native_contact.dart';

abstract interface class IContactsRepository {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<List<NativeContact>> fetchAll({String query = ''});
}
