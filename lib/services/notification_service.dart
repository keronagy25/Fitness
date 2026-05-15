import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:js' as js;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initialize() async {
    if (kIsWeb) {
      // Request browser notification permission
      js.context.callMethod('eval', [
        '''
        if (Notification.permission !== "granted") {
          Notification.requestPermission();
        }
        '''
      ]);
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
  }

  // Show notification
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      // Use browser notification
      js.context.callMethod('eval', [
        '''
        if (Notification.permission === "granted") {
          new Notification("$title", { body: "$body" });
        }
        '''
      ]);
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fitness_channel',
      'Fitness Notifications',
      channelDescription: 'Fitness Tracker Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(0, title, body, details);
  }

  // Show workout reminder
  Future<void> showWorkoutReminder() async {
    await showNotification(
      title: '💪 Workout Logged!',
      body: 'Great job! Keep up the good work!',
    );
  }

  // Show water reminder
  Future<void> showWaterReminder() async {
    await showNotification(
      title: '🥤 Drink Water!',
      body: 'Stay hydrated! Drink a glass of water now.',
    );
  }

  // Show goal reminder
  Future<void> showGoalReminder() async {
    await showNotification(
      title: '🎯 Daily Goal!',
      body: 'You are close to reaching your daily goal!',
    );
  }
}