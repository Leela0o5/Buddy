import '../models/focus_session.dart';
import '../models/energy_log.dart';

// Service for calculating analytics and insights
class AnalyticsService {
  // Calculate total focus time in minutes for today
  static int calculateTodayFocusTime(List<FocusSession> sessions) {
    final today = DateTime.now();
    return sessions
        .where((s) =>
            s.startedAt.year == today.year &&
            s.startedAt.month == today.month &&
            s.startedAt.day == today.day &&
            s.completed)
        .fold<int>(0, (total, session) => total + session.durationMinutes);
  }

  // Calculate total focus time for week (last 7 days)
  static int calculateWeeklyFocusTime(List<FocusSession> sessions) {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return sessions
        .where((s) =>
            s.startedAt.isAfter(sevenDaysAgo) &&
            s.completed)
        .fold<int>(0, (total, session) => total + session.durationMinutes);
  }

  // Count completed sessions today
  static int countTodayCompletedSessions(List<FocusSession> sessions) {
    final today = DateTime.now();
    return sessions
        .where((s) =>
            s.startedAt.year == today.year &&
            s.startedAt.month == today.month &&
            s.startedAt.day == today.day &&
            s.completed)
        .length;
  }

  // Calculate average distraction count per session
  static double calculateAverageDistractionRate(List<FocusSession> sessions) {
    final completedSessions = sessions.where((s) => s.completed).toList();
    if (completedSessions.isEmpty) return 0;

    final totalDistractions = completedSessions.fold<int>(
        0, (total, session) => total + session.distractionsCount);
    return totalDistractions / completedSessions.length;
  }

  // Get best focus hours (hour of day with most completed sessions)
  static Map<int, int> calculateBestFocusHours(List<FocusSession> sessions) {
    final hourCounts = <int, int>{};

    for (final session in sessions) {
      if (session.completed) {
        final hour = session.startedAt.hour;
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    return hourCounts;
  }

  // Get best focus hour (single hour with most completed sessions)
  static int? getBestFocusHour(List<FocusSession> sessions) {
    final hourCounts = calculateBestFocusHours(sessions);
    if (hourCounts.isEmpty) return null;

    int bestHour = 0;
    int maxCount = 0;

    hourCounts.forEach((hour, count) {
      if (count > maxCount) {
        maxCount = count;
        bestHour = hour;
      }
    });

    return bestHour;
  }

  // Detect burnout risk: 4+ sessions in 2-hour window
  static bool detectBurnoutRisk(List<FocusSession> sessions) {
    final recentSessions = sessions
        .where((s) =>
            s.startedAt.isAfter(
              DateTime.now().subtract(const Duration(hours: 2)),
            ) &&
            s.completed)
        .toList();

    return recentSessions.length >= 4;
  }

  // Detect focus drift: high abandonment rate
  static bool detectFocusDrift(List<FocusSession> sessions) {
    if (sessions.isEmpty) return false;

    final abandonedCount = sessions.where((s) => !s.completed).length;
    final abandonmentRate = abandonedCount / sessions.length;

    return abandonmentRate > 0.3;
  }

  // Get 7-day focus time history (daily totals)
  static List<int> getWeeklyFocusTimeHistory(List<FocusSession> sessions) {
    final history = <int>[];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayTotal = sessions
          .where((s) =>
              s.startedAt.year == date.year &&
              s.startedAt.month == date.month &&
              s.startedAt.day == date.day &&
              s.completed)
          .fold<int>(0, (total, session) => total + session.durationMinutes);
      history.add(dayTotal);
    }

    return history;
  }

  // Get average session duration
  static double calculateAverageSessionDuration(List<FocusSession> sessions) {
    final completedSessions = sessions.where((s) => s.completed).toList();
    if (completedSessions.isEmpty) return 0;

    final totalMinutes = completedSessions.fold<int>(
        0, (total, session) => total + session.durationMinutes);
    return totalMinutes / completedSessions.length;
  }

  // Get completion rate (completed / total)
  static double calculateCompletionRate(List<FocusSession> sessions) {
    if (sessions.isEmpty) return 0;

    final completed = sessions.where((s) => s.completed).length;
    return (completed / sessions.length) * 100;
  }

  // Calculate average energy level from reflections
  static double calculateAverageEnergyLevel(List<EnergyLog> energyLogs) {
    if (energyLogs.isEmpty) return 0;

    int totalEnergy = 0;
    for (final log in energyLogs) {
      switch (log.energyLevel) {
        case EnergyLevel.low:
          totalEnergy += 1;
        case EnergyLevel.medium:
          totalEnergy += 2;
        case EnergyLevel.high:
          totalEnergy += 3;
      }
    }

    return totalEnergy / energyLogs.length;
  }

  // Get most common focus helpers from reflections
  static List<String> getMostCommonHelpers(
    List<EnergyLog> energyLogs, {
    int topCount = 5,
  }) {
    final helperCounts = <String, int>{};

    for (final log in energyLogs) {
      if (log.reflectionNotes != null && log.reflectionNotes!.isNotEmpty) {
        // Simple keyword extraction
        final words = log.reflectionNotes!
            .toLowerCase()
            .split(RegExp(r'[,.\s]+'))
            .where((w) => w.isNotEmpty && w.length > 3)
            .toList();

        for (final word in words) {
          helperCounts[word] = (helperCounts[word] ?? 0) + 1;
        }
      }
    }

    // Sort by frequency and return top helpers
    final sorted = helperCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(topCount).map((e) => e.key).toList();
  }
}
