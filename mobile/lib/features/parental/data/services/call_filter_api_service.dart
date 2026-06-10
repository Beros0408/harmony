import '../../../../core/services/harmony_services.dart';
import '../models/blocked_call_log.dart';
import '../models/call_filter_rule.dart';

class CallFilterApiService {
  CallFilterApiService._();
  static final CallFilterApiService instance = CallFilterApiService._();

  Future<({CallFilterSettings settings, List<CallFilterRule> rules})> getRules(
      String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>('/api/v1/call-filter-rules/$childId');
    final data = response.data!;
    final settingsJson = data['settings'] as Map<String, dynamic>?;
    final rulesJson = data['rules'] as List<dynamic>? ?? [];
    final settings = settingsJson != null
        ? CallFilterSettings.fromJson(settingsJson)
        : CallFilterSettings.defaults;
    final rules = rulesJson
        .whereType<Map<String, dynamic>>()
        .map(CallFilterRule.fromJson)
        .toList();
    return (settings: settings, rules: rules);
  }

  Future<CallFilterRule> addRule(
    String childId,
    String phoneNumber,
    ListMode listType, {
    String? label,
  }) async {
    final response = await HarmonyServices.dioClient.instance
        .post<Map<String, dynamic>>(
      '/api/v1/call-filter-rules/$childId',
      data: {
        'phone_number': phoneNumber,
        'list_type': listType.name,
        'created_by': 'parent',
        if (label != null && label.isNotEmpty) 'label': label,
      },
    );
    return CallFilterRule.fromJson(response.data!);
  }

  Future<void> deleteRule(String ruleId) async {
    await HarmonyServices.dioClient.instance
        .delete<void>('/api/v1/call-filter-rules/$ruleId');
  }

  Future<void> updateSettings(String childId, ListMode listMode) async {
    await HarmonyServices.dioClient.instance.put<void>(
      '/api/v1/call-filter-settings/$childId',
      data: {
        'list_mode': listMode.name,
        'updated_by': 'parent',
      },
    );
  }

  Future<List<BlockedCallLog>> getBlockedCalls(
    String childId, {
    int limit = 50,
  }) async {
    final response = await HarmonyServices.dioClient.instance
        .get<Map<String, dynamic>>(
      '/api/v1/blocked-calls/$childId',
      queryParameters: {'limit': limit},
    );
    final calls = response.data!['calls'] as List<dynamic>? ?? [];
    return calls
        .whereType<Map<String, dynamic>>()
        .map(BlockedCallLog.fromJson)
        .toList();
  }
}
