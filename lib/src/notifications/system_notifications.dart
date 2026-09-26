import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../i18n/tr.dart';
import 'app_notification.dart';

/// Shows backend notifications as Android/iOS system notifications while the
/// app is running (foreground or background). Delivery when the app is fully
/// closed needs server push (Firebase Cloud Messaging).
class SystemNotifications {
  SystemNotifications._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static AndroidNotificationDetails get _channel => AndroidNotificationDetails(
        'immoizi_activity',
        tr('Activité Immoizi'),
        channelDescription: tr('Demandes, réponses et propositions de visite'),
        importance: Importance.high,
        priority: Priority.high,
      );

  /// Initialises the plugin and asks for the permission (Android 13+, iOS).
  /// Safe to call repeatedly; failures (tests, unsupported platforms) are
  /// ignored so the app keeps working without system notifications.
  static Future<void> initialize() async {
    if (_ready) return;
    try {
      await _plugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ));
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  static Future<void> show(AppNotification notification) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        notification.id.hashCode & 0x7fffffff,
        notification.title,
        notification.message,
        NotificationDetails(
            android: _channel, iOS: const DarwinNotificationDetails()),
      );
    } catch (_) {
      // Showing an alert is best effort; the in-app badge still updates.
    }
  }
}
