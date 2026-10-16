import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationDetails(
    'default_channel',
    'Default',
    importance: Importance.max,
    priority: Priority.high,
  );

  static Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(settings: settings);

    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    try {
      // ignore: deprecated_member_use
      final token = await _fcm.getToken();
      // ignore: avoid_print
      print('FCM TOKEN: $token');
    } catch (e) {
      // ignore: avoid_print
      print('FCM token недоступен: $e');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      final n = m.notification;
      if (n != null) {
        show(n.title ?? 'Уведомление', n.body ?? '');
      }
    });
  }

  static Future<void> show(String title, String body) async {
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: _channel,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
