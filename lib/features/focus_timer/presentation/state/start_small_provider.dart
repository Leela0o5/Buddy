import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for Start Small Mode state
final startSmallModeProvider = StateProvider<bool>((ref) => false);

// Provider to activate Start Small Mode with optional duration
final activateStartSmallProvider =
    FutureProvider.family.autoDispose<void, int?>(
  (ref, customDuration) async {
    // Set Start Small mode to active
    ref.read(startSmallModeProvider.notifier).state = true;

    // Reset after 2 seconds (visual indication)
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(startSmallModeProvider.notifier).state = false;
  },
);

// Get the recommended Start Small duration
final recommendedStartSmallDurationProvider = Provider<int>((ref) {
  // Default 5 minutes for Start Small
  return 5;
});
