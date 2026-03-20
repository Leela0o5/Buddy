import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/presentation/state/preferences_provider.dart';

// Theme mode provider - reactive to dark mode setting
final themeModeProvider = Provider<ThemeMode>((ref) {
  final enabled = ref.watch(darkModeProvider);
  return enabled ? ThemeMode.dark : ThemeMode.light;
});
