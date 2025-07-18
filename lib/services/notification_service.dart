import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request permissions for Firebase Messaging
    await _requestFirebasePermissions();
  }
  
  Future<void> _requestFirebasePermissions() async {
    final messaging = FirebaseMessaging.instance;
    
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // User granted permission - notifications enabled
    } else {
      // User declined or has not accepted permission
    }
  }
  
  Future<void> scheduleDefaultDailyNotification() async {
    await _localNotifications.zonedSchedule(
      0,
      'Devocional do Dia 🙏',
      'Clique e veja sua mensagem de hoje',
      _nextInstanceOf8AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'devotional_notifications',
          'Daily Devotionals',
          channelDescription: 'Notifications for daily devotional messages',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  tz.TZDateTime _nextInstanceOf8AM() {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, 8);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return tz.TZDateTime.from(scheduledDate, tz.getLocation('America/Sao_Paulo'));
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to home screen
    // TODO: Implement navigation to home screen when notification is tapped
  }
  
  Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
  
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
  
  /// Schedule a daily notification at a specific time
  Future<void> scheduleDailyNotification({
    required int notificationId,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _localNotifications.zonedSchedule(
      notificationId,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_reminders',
          'Reading Reminders',
          channelDescription: 'Notifications to remind you to read daily devotionals',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  /// Show an immediate notification
  Future<void> showNotification({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    await _localNotifications.show(
      notificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'milestone_notifications',
          'Milestone Notifications',
          channelDescription: 'Notifications for reading streak milestones',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
  
  /// Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    await _localNotifications.cancel(notificationId);
  }
  
  /// Get next instance of specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return tz.TZDateTime.from(scheduledDate, tz.getLocation('America/Sao_Paulo'));
  }
}