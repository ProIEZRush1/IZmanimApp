import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/notification_preference.dart';
import '../models/zman.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
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
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String timezone,
  }) async {
    if (!_initialized) await initialize();

    final location = tz.getLocation(timezone);
    final scheduledTZ = tz.TZDateTime.from(scheduledTime, location);

    // Don't schedule notifications in the past
    if (scheduledTZ.isBefore(tz.TZDateTime.now(location))) return;

    const androidDetails = AndroidNotificationDetails(
      'zmanim_notifications',
      'Zmanim Notifications',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZ,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> scheduleZmanNotifications({
    required List<NotificationPreference> preferences,
    required List<Zman> zmanim,
    required DateTime date,
    required String timezone,
    required String lang,
  }) async {
    // Cancel all existing scheduled notifications first
    await cancelAllNotifications();

    for (final pref in preferences) {
      if (!pref.shouldNotifyOn(date)) continue;

      final zman = zmanim.where((z) => z.key == pref.zmanKey).firstOrNull;
      if (zman == null || zman.time == null) continue;

      // Parse the zman time (format: "HH:mm")
      final parts = zman.time!.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      var scheduledTime = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      ).subtract(Duration(minutes: pref.minutesBefore));

      final title = pref.minutesBefore > 0
          ? '${pref.zmanName} ${_getInText(lang)} ${pref.minutesBefore} ${_getMinutesText(lang)}'
          : pref.zmanName;
      final body = '${zman.time}';

      // Generate a stable notification ID from preference ID
      final notifId = pref.id.hashCode.abs() % 100000;

      await scheduleNotification(
        id: notifId,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        timezone: timezone,
      );
    }
  }

  String _getInText(String lang) {
    switch (lang) {
      case 'es':
        return 'en';
      case 'he':
        return 'בעוד';
      case 'ar':
        return 'في';
      case 'fr':
        return 'dans';
      default:
        return 'in';
    }
  }

  String _getMinutesText(String lang) {
    switch (lang) {
      case 'es':
        return 'minutos';
      case 'he':
        return 'דקות';
      case 'ar':
        return 'دقائق';
      case 'fr':
        return 'minutes';
      default:
        return 'minutes';
    }
  }
}
