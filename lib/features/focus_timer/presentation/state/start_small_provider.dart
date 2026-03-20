import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for Start Small Mode state
final startSmallModeProvider = StateProvider<bool>((ref) => false);

// Trigger Start Small visual state without mutating providers during provider build.
typedef StartSmallActivator = Future<void> Function(int? customDuration);

final activateStartSmallProvider = Provider<StartSmallActivator>((ref) {
  return (int? customDuration) async {
    ref.read(startSmallModeProvider.notifier).state = true;

    // Brief pulse animation to indicate Start Small was activated.
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(startSmallModeProvider.notifier).state = false;
  };
});

// Get the recommended Start Small duration
final recommendedStartSmallDurationProvider = Provider<int>((ref) {
  // Default 5 minutes for Start Small
  return 5;
});
