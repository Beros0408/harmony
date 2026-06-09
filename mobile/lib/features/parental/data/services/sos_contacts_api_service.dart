import '../../../../core/services/harmony_services.dart';
import '../models/sos_contact.dart';

class SosContactsApiService {
  SosContactsApiService._();
  static final SosContactsApiService instance = SosContactsApiService._();

  Future<List<SosContact>> getContacts(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<List<dynamic>>('/api/v1/sos-contacts/$childId');
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(SosContact.fromJson)
        .toList();
  }

  Future<SosContact> addContact(
    String childId,
    String name,
    String phone,
    String createdBy,
  ) async {
    final response = await HarmonyServices.dioClient.instance
        .post<Map<String, dynamic>>(
      '/api/v1/sos-contacts/$childId',
      data: {'name': name, 'phone': phone, 'created_by': createdBy},
    );
    return SosContact.fromJson(response.data!);
  }

  Future<void> deleteContact(String contactId) async {
    await HarmonyServices.dioClient.instance
        .delete<void>('/api/v1/sos-contacts/$contactId');
  }

  Future<void> updateOrder(String contactId, int sortOrder) async {
    await HarmonyServices.dioClient.instance.patch<void>(
      '/api/v1/sos-contacts/$contactId',
      data: {'sort_order': sortOrder},
    );
  }
}
