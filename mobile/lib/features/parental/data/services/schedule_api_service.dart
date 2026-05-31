import '../../../../core/services/harmony_services.dart';

/// Plage horaire telle que retournée par le backend.
class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.childId,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.active,
  });

  final String id;
  final String childId;
  final String label;
  final String startTime; // "HH:MM"
  final String endTime;   // "HH:MM"
  final List<int> daysOfWeek; // 1=lun … 7=dim
  final bool active;
}

/// CRUD des plages horaires de verrouillage depuis l'app parent.
class ScheduleApiService {
  ScheduleApiService._();
  static final ScheduleApiService instance = ScheduleApiService._();

  Future<List<ScheduleItem>> getSchedules(String childId) async {
    final response = await HarmonyServices.dioClient.instance
        .get<List<dynamic>>(
      '/api/v1/schedules',
      queryParameters: {'child_id': childId},
    );

    final list = response.data ?? [];
    return list.whereType<Map<String, dynamic>>().map((m) {
      return ScheduleItem(
        id: m['id'] as String,
        childId: m['child_id'] as String,
        label: m['label'] as String? ?? '',
        startTime: m['start_time'] as String,
        endTime: m['end_time'] as String,
        daysOfWeek: (m['days_of_week'] as List<dynamic>)
            .map((d) => d as int)
            .toList(),
        active: m['active'] as bool? ?? true,
      );
    }).toList();
  }

  Future<void> createSchedule({
    required String childId,
    required String label,
    required String startTime,
    required String endTime,
    required List<int> daysOfWeek,
  }) async {
    await HarmonyServices.dioClient.instance.post<void>(
      '/api/v1/schedules',
      data: {
        'child_id': childId,
        'label': label,
        'start_time': startTime,
        'end_time': endTime,
        'days_of_week': daysOfWeek,
      },
    );
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await HarmonyServices.dioClient.instance
        .delete<void>('/api/v1/schedules/$scheduleId');
  }
}
