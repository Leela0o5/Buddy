import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/distraction_service.dart';

// Distraction service provider
final distractionServiceProvider = Provider((ref) {
  final service = DistractionService();
  service.startMonitoring();
  
  // Cleanup on dispose
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// Stream of distraction count updates
final distractionStreamProvider =
    StreamProvider.autoDispose<int>((ref) {
  final distractionService = ref.watch(distractionServiceProvider);
  return distractionService.distractionStream;
});

// Current distraction count
final currentDistractionCountProvider =
    StateProvider<int>((ref) => 0);

// Track distraction in current session
final recordDistractionProvider =
    FutureProvider.family.autoDispose<void, int>((ref, count) async {
  ref.watch(currentDistractionCountProvider.notifier).state = count;
});