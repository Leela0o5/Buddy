import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/focus_session.dart';
import '../../../../core/services/timer_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/hive_storage_service.dart';
import '../../data/repositories/focus_session_repository.dart';



// Single instance of TimerService
final timerServiceProvider = Provider((ref) => TimerService());

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return HiveStorageService();
});

// Focus session repository provider
final focusSessionRepositoryProvider = Provider((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return FocusSessionRepository(storageService: storageService);
});

// State Providers 

// Selected focus duration (5, 10, 15, or 25)
final selectedDurationProvider = StateProvider<int>((ref) => 15);

// Current active focus session
final currentSessionProvider = StateNotifierProvider<
    CurrentSessionNotifier,
    FocusSession?>((ref) {
  return CurrentSessionNotifier();
});

// Manages the current focus session state
class CurrentSessionNotifier extends StateNotifier<FocusSession?> {
  CurrentSessionNotifier() : super(null);

  void startSession(int durationMinutes) {
    state = FocusSession(
      durationMinutes: durationMinutes,
      completed: false,
    );
  }

  void updateElapsedTime(int elapsedSeconds) {
    if (state != null) {
      state = state!.copyWith(elapsedSeconds: elapsedSeconds);
    }
  }

  void recordDistraction() {
    if (state != null) {
      state = state!.copyWith(
        distractionsCount: state!.distractionsCount + 1,
      );
    }
  }

  void completeSession() {
    if (state != null) {
      state = state!.copyWith(
        completed: true,
        endedAt: DateTime.now(),
      );
    }
  }

  void abandonSession() {
    if (state != null) {
      state = state!.copyWith(
        completed: false,
        endedAt: DateTime.now(),
      );
    }
  }

  void resetSession() {
    state = null;
  }
}



// Timer elapsed time stream (updates every 100ms)
final timerStreamProvider =
    StreamProvider.autoDispose<int>((ref) {
  final timerService = ref.watch(timerServiceProvider);
  return timerService.elapsedStream;
});


// Get all focus sessions 
final allSessionsProvider =
    FutureProvider.autoDispose<List<FocusSession>>((ref) async {
  final repository = ref.watch(focusSessionRepositoryProvider);
  return repository.getAll();
});

// Get today's sessions
final todaySessionsProvider =
    FutureProvider.autoDispose<List<FocusSession>>((ref) async {
  final repository = ref.watch(focusSessionRepositoryProvider);
  return repository.getTodaySessions();
});

// Get current streak
final currentStreakProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(focusSessionRepositoryProvider);
  return repository.getCurrentStreak();
});

// Count today's completed sessions
final todayCompletedCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final sessions = await ref.watch(todaySessionsProvider.future);
  return sessions.where((s) => s.completed).length;
});