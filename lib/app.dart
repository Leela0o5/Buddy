import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/constants.dart';

/// Main app widget 
class Buddy extends ConsumerWidget {
  const Buddy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme provider from settings provider
    return MaterialApp(
      title: AppConstants.appName,
      theme: createLightTheme(),
      darkTheme: createDarkTheme(),
      themeMode: ThemeMode.light, // Placeholder
      home: const Placeholder(), // Will be replaced with navigation structure
      debugShowCheckedModeBanner: false,
    );
  }
}