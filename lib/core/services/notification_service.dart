import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Service to send local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  factory NotificationService() => _instance;

  NotificationService._internal();

  // Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    try {
      await _flutterLocalNotificationsPlugin.initialize(settings);
      _isInitialized = true;
      debugPrint('Notifications initialized');
    } catch (e) {
      debugPrint('Warning: Notifications not fully available on this platform: $e');
      _isInitialized = false; // Allow app to continue without notifications
    }
  }

  // Show distraction alert notification
  Future<void> showDistractionAlert() async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'distraction_channel',
      'Distraction Alerts',
      channelDescription: 'Alerts when user gets distracted',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Looks like you got distracted! 👀',
      'Want to resume your focus session?',
      details,
    );
  }

  // Show break reminder
  Future<void> showBreakReminder() async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'break_channel',
      'Break Reminders',
      channelDescription: 'Reminders to take breaks',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      1,
      'Time for a break! 😊',
      "You've been focusing well. Take a moment to rest.",
      details,
    );
  }

  // Show encouragement notification
  Future<void> showEncouragement(String message) async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'encouragement_channel',
      'Encouragement',
      channelDescription: 'Positive encouragement messages',
      importance: Importance.low,
      priority: Priority.low,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      2,
      '💪 Keep Going!',
      message,
      details,
    );
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}