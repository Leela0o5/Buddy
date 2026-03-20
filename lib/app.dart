import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'config/router.dart';
import 'config/theme_provider.dart';

/// Main app widget with Riverpod and theme setup
class Buddy extends ConsumerWidget {
  const Buddy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      theme: createLightTheme(),
      darkTheme: createDarkTheme(),
      themeMode: themeMode,
      home: const MainNavigationShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}