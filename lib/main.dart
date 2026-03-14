import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/hive_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await HiveService().initialize();

  // Initialize local notifications later

  runApp(
    const ProviderScope(
      child: Buddy(),
    ),
  );
}