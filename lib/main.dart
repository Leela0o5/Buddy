import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  try {
    // Initialize Hive for local storage
    await HiveService().initialize();
  } catch (e) {
    debugPrint('Error initializing Hive: $e');
  }

  try {
    // Initialize local notifications
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }


  runApp(
    const ProviderScope(
      child: Buddy(),
    ),
  );
}