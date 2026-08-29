import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications for optional plant-care reminders. Notifications are
/// only ever scheduled after the user explicitly enables reminders and grants
/// permission. Nothing is scheduled at startup.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialised = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'plant_care_reminders',
    'Plant care reminders',
    description: 'Watering, fertilizing and inspection reminders.',
    importance: Importance.defaultImportance,
  );

  Future<void> init() async {
    if (_initialised) return;
    tzdata.initializeTimeZones();
    await _setLocalTimeZone();
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
    _initialised = true;
  }

  /// Points `tz.local` at the device's zone. Without this it stays UTC, so a
  /// reminder picked for 23:00 would be scheduled as 23:00 UTC — and because
  /// weekly reminders match on weekday *and* time, an off-UTC user could get
  /// them on the wrong day entirely.
  Future<void> _setLocalTimeZone() async {
    try {
      final String name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Unknown/unavailable zone: fall back to the UTC default rather than
      // preventing reminders from being scheduled at all.
    }
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    bool repeatsDaily = false,
    bool repeatsWeekly = false,
  }) async {
    await init();
    final tz.TZDateTime when = tz.TZDateTime.from(scheduledAt, tz.local);
    // Genuine scheduling failures (e.g. the OS rejecting the request or a
    // revoked permission) must propagate so the caller can revert the
    // reminder's enabled state instead of presenting a schedule that was never
    // actually accepted. Callers are responsible for logging/degrading.
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // `time` repeats every day at the same clock time;
      // `dayOfWeekAndTime` repeats on the same weekday each week.
      matchDateTimeComponents: repeatsWeekly
          ? DateTimeComponents.dayOfWeekAndTime
          : repeatsDaily
          ? DateTimeComponents.time
          : null,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
