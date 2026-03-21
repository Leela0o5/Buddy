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

  void adjustDuration(int newDuration) {
    if (state != null && state!.elapsedSeconds == 0) {
      // Only allow adjustment before timer starts or at start
      state = state!.copyWith(durationMinutes: newDuration);
    }
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

// Track if session is currently active (for locking home screen)
final isSessionActiveProvider = StateProvider<bool>((ref) {
  final currentSession = ref.watch(currentSessionProvider);
  return currentSession != null;
});

// Determine if reflection should be shown (after every 3 sessions)
final shouldShowReflectionProvider = FutureProvider.autoDispose<bool>((ref) async {
  final sessions = await ref.watch(todaySessionsProvider.future);
  final completedCount = sessions.where((s) => s.completed).length;
  // Show reflection after every 3 sessions
  return (completedCount + 1) % 3 == 0;
});

// Track break state
final breakStateProvider = StateNotifierProvider<BreakStateNotifier, BreakState?>((ref) {
  return BreakStateNotifier();
});

class BreakState {
  final int durationSeconds;
  final int remainingSeconds;
  final bool isRunning;

  BreakState({
    required this.durationSeconds,
    required this.remainingSeconds,
    required this.isRunning,
  });

  BreakState copyWith({
    int? durationSeconds,
    int? remainingSeconds,
    bool? isRunning,
  }) {
    return BreakState(
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class BreakStateNotifier extends StateNotifier<BreakState?> {
  BreakStateNotifier() : super(null);

  void startBreak(int minutes) {
    state = BreakState(
      durationSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      isRunning: true,
    );
  }

  void updateRemaining(int remaining) {
    if (state != null) {
      state = state!.copyWith(remainingSeconds: remaining);
    }
  }

  void pauseBreak() {
    if (state != null) {
      state = state!.copyWith(isRunning: false);
    }
  }

  void resumeBreak() {
    if (state != null) {
      state = state!.copyWith(isRunning: true);
    }
  }

  void endBreak() {
    state = null;
  }
}

// Determine break duration based on Pomodoro cycle
final breakDurationProvider = FutureProvider.autoDispose<int>((ref) async {
  final sessions = await ref.watch(todaySessionsProvider.future);
  final completedCount = sessions.where((s) => s.completed).length;
  
  // After every 4 sessions, give a long break (25 minutes)
  // Otherwise, short break (5 minutes)
  if (completedCount > 0 && completedCount % 4 == 0) {
    return 25; // Long break
  }
  return 5; // Short break
});

// Determine if current break is long or short
final isLongBreakProvider = FutureProvider.autoDispose<bool>((ref) async {
  final duration = await ref.watch(breakDurationProvider.future);
  return duration >= 15;
});

// Get break tips based on break type
final breakTipsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final isLongBreak = await ref.watch(isLongBreakProvider.future);
  
  if (isLongBreak) {
    return [
      '🚶 Take a walk around your space',
      '👀 Rest your eyes - look away from screens',
      '💧 Drink water and stay hydrated',
      '🧘 Do some light stretching or yoga',
      '🎵 Listen to your favorite music',
      '🌬️ Take deep breaths and meditate',
    ];
  } else {
    return [
      '💧 Grab a glass of water',
      '👀 Look away from the screen',
      '🧘 Take 3-5 deep breaths',
      '🚶 Stand up and stretch quickly',
      '🌬️ Clear your mind and relax',
      '⚡ Reset before your next session',
    ];
  }
});