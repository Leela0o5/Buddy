import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../../../features/focus_timer/presentation/state/timer_provider.dart';
import '../../../../features/reflection/presentation/state/reflection_provider.dart';

// Analytics repository provider
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(
    focusSessionRepository: ref.watch(focusSessionRepositoryProvider),
    reflectionRepository: ref.watch(reflectionRepositoryProvider),
  );
});

// Today's focus time provider
final todayFocusTimeProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getTodayFocusTime();
});

// Weekly focus time provider
final weeklyFocusTimeProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getWeeklyFocusTime();
});

// Today's session count provider
final todaySessionCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getTodaySessionCount();
});

// Average distraction rate provider
final averageDistractionRateProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getAverageDistractionRate();
});

// Best focus hour provider
final bestFocusHourProvider = FutureProvider<int?>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getBestFocusHour();
});

// Burnout risk provider
final burnoutRiskProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.checkBurnoutRisk();
});

// Focus drift provider
final focusDriftProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.checkFocusDrift();
});

// Weekly focus time history provider
final weeklyFocusTimeHistoryProvider = FutureProvider<List<int>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getWeeklyFocusTimeHistory();
});

// Average session duration provider
final averageSessionDurationProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getAverageSessionDuration();
});

// Completion rate provider
final completionRateProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getCompletionRate();
});

// Average energy level provider
final averageEnergyLevelProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getAverageEnergyLevel();
});

// Today's average energy level provider
final todayAverageEnergyProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getTodayAverageEnergyLevel();
});

// Most common helpers provider
final mostCommonHelpersProvider =
    FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getMostCommonHelpers(topCount: 5);
});

// All-time stats provider
final allTimeStatsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getAllTimeStats();
});
