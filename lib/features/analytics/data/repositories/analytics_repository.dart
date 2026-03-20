import '../../../focus_timer/data/repositories/focus_session_repository.dart';
import '../../../reflection/data/repositories/reflection_repository.dart';
import '../../../../core/services/analytics_service.dart';

// Repository for analytics and insights
class AnalyticsRepository {
  final FocusSessionRepository focusSessionRepository;
  final ReflectionRepository reflectionRepository;

  AnalyticsRepository({
    required this.focusSessionRepository,
    required this.reflectionRepository,
  });

  // Get today's focus time (minutes)
  Future<int> getTodayFocusTime() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.calculateTodayFocusTime(sessions);
  }

  // Get weekly focus time (minutes)
  Future<int> getWeeklyFocusTime() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.calculateWeeklyFocusTime(sessions);
  }

  // Get today's completed session count
  Future<int> getTodaySessionCount() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.countTodayCompletedSessions(sessions);
  }

  // Get average distraction rate
  Future<double> getAverageDistractionRate() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.calculateAverageDistractionRate(sessions);
  }

  // Get best focus hour
  Future<int?> getBestFocusHour() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.getBestFocusHour(sessions);
  }

  // Check for burnout risk
  Future<bool> checkBurnoutRisk() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.detectBurnoutRisk(sessions);
  }

  // Check for focus drift
  Future<bool> checkFocusDrift() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.detectFocusDrift(sessions);
  }

  // Get 7-day focus time history
  Future<List<int>> getWeeklyFocusTimeHistory() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.getWeeklyFocusTimeHistory(sessions);
  }

  // Get average session duration
  Future<double> getAverageSessionDuration() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.calculateAverageSessionDuration(sessions);
  }

  // Get completion rate percentage
  Future<double> getCompletionRate() async {
    final sessions = await focusSessionRepository.getAll();
    return AnalyticsService.calculateCompletionRate(sessions);
  }

  // Get average energy level from reflections
  Future<double> getAverageEnergyLevel() async {
    final energyLogs = await reflectionRepository.getAllEnergyLogs();
    return AnalyticsService.calculateAverageEnergyLevel(energyLogs);
  }

  // Get today's average energy level
  Future<double> getTodayAverageEnergyLevel() async {
    return reflectionRepository.getTodayAverageEnergyLevel();
  }

  // Get most common focus helpers
  Future<List<String>> getMostCommonHelpers({int topCount = 5}) async {
    final energyLogs = await reflectionRepository.getAllEnergyLogs();
    return AnalyticsService.getMostCommonHelpers(energyLogs, topCount: topCount);
  }

  // Get all-time stats summary
  Future<Map<String, dynamic>> getAllTimeStats() async {
    final sessions = await focusSessionRepository.getAll();
    final energyLogs = await reflectionRepository.getAllEnergyLogs();

    return {
      'totalSessions': sessions.length,
      'completedSessions': sessions.where((s) => s.completed).length,
      'totalFocusMinutes':
          sessions.fold<int>(0, (total, s) => total + s.durationMinutes),
      'averageSessionDuration':
          AnalyticsService.calculateAverageSessionDuration(sessions),
      'completionRate': AnalyticsService.calculateCompletionRate(sessions),
      'averageDistractionRate':
          AnalyticsService.calculateAverageDistractionRate(sessions),
      'averageEnergyLevel':
          AnalyticsService.calculateAverageEnergyLevel(energyLogs),
      'totalReflections': energyLogs.length,
    };
  }
}
