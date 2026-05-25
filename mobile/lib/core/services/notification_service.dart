import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/agenda/data/models/agenda_event.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _androidChannelId = 'harmony_agenda';
  static const _androidChannelName = 'Agenda Harmony';
  static const _androidChannelDesc = 'Rappels d\'événements agenda';

  final _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    // Crée le canal Android (requis Android 8+)
    const channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDesc,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// Programme un rappel [reminderMinutesBefore] minutes avant l'événement.
  Future<void> scheduleReminder(AgendaEvent event) async {
    await scheduleSmartReminder(event, 0);
  }

  /// Programme un rappel intégrant le temps de trajet estimé.
  /// La notif se déclenche [travelTimeMinutes + reminderMinutesBefore] min avant le début.
  Future<void> scheduleSmartReminder(
    AgendaEvent event,
    int travelTimeMinutes,
  ) async {
    final totalMinutes = event.reminderMinutesBefore + travelTimeMinutes;
    final fireAt = event.startDate.subtract(Duration(minutes: totalMinutes));

    if (fireAt.isBefore(DateTime.now())) return;

    final tzFireAt = tz.TZDateTime.from(fireAt, tz.local);
    final notifId = _idFromEventId(event.id);

    await _plugin.zonedSchedule(
      notifId,
      event.title,
      _buildBody(event, travelTimeMinutes),
      tzFireAt,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelReminder(String eventId) async {
    await _plugin.cancel(_idFromEventId(eventId));
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Convertit les 8 premiers hex chars de l'UUID en int stable pour l'ID notif
  int _idFromEventId(String eventId) {
    final hex = eventId.replaceAll('-', '').substring(0, 8);
    return int.parse(hex, radix: 16) & 0x7FFFFFFF;
  }

  String _buildBody(AgendaEvent event, int travelTimeMinutes) {
    if (event.location != null && event.location!.isNotEmpty) {
      if (travelTimeMinutes > 0) {
        return 'Départ dans ${event.reminderMinutesBefore} min · '
            'Trajet estimé $travelTimeMinutes min · ${event.location}';
      }
      return 'Dans ${event.reminderMinutesBefore} min · ${event.location}';
    }
    return 'Dans ${event.reminderMinutesBefore} min';
  }
}
