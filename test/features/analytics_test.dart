import 'package:flutter_test/flutter_test.dart';
import 'package:buddy/core/models/focus_session.dart';

void main() {
  group('Analytics Feature Tests', () {
    test('Focus time calculation', () {
      final now = DateTime.now();
      final sessions = [
        FocusSession(
          id: '1',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: now,
          endedAt: now.add(const Duration(minutes: 25)),
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '2',
          durationMinutes: 15,
          elapsedSeconds: 900,
          startedAt: now.add(const Duration(hours: 1)),
          endedAt: now.add(const Duration(hours: 1, minutes: 15)),
          completed: true,
          distractionsCount: 1,
        ),
      ];

      final totalMinutes =
          sessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
      expect(totalMinutes, 40);
    });

    test('Completion rate calculation', () {
      final sessions = [
        FocusSession(
          id: '1',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime.now(),
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '2',
          durationMinutes: 25,
          elapsedSeconds: 300,
          startedAt: DateTime.now(),
          completed: false,
          distractionsCount: 2,
        ),
        FocusSession(
          id: '3',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime.now(),
          completed: true,
          distractionsCount: 0,
        ),
      ];

      final completed =
          sessions.where((s) => s.completed).length;
      final completionRate = completed / sessions.length;

      expect(completed, 2);
      expect(completionRate, 2 / 3);
    });

    test('Burnout detection (4+ sessions in 2 hours)', () {
      final now = DateTime.now();
      final sessions = [
        FocusSession(
          id: '1',
          durationMinutes: 5,
          elapsedSeconds: 300,
          startedAt: now,
          endedAt: now.add(const Duration(minutes: 5)),
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '2',
          durationMinutes: 5,
          elapsedSeconds: 300,
          startedAt: now.add(const Duration(minutes: 10)),
          endedAt: now.add(const Duration(minutes: 15)),
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '3',
          durationMinutes: 5,
          elapsedSeconds: 300,
          startedAt: now.add(const Duration(minutes: 20)),
          endedAt: now.add(const Duration(minutes: 25)),
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '4',
          durationMinutes: 5,
          elapsedSeconds: 300,
          startedAt: now.add(const Duration(minutes: 30)),
          endedAt: now.add(const Duration(minutes: 35)),
          completed: true,
          distractionsCount: 0,
        ),
      ];

      // Simple burnout check: 4+ sessions within 2 hour window
      final recentSessions =
          sessions.where((s) => s.endedAt!.difference(now).inHours <= 2);
      final burnoutRisk = recentSessions.length >= 4;

      expect(burnoutRisk, true);
    });

    test('Focus drift detection (>30% abandonment)', () {
      final sessions = [
        FocusSession(
          id: '1',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime.now(),
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '2',
          durationMinutes: 25,
          elapsedSeconds: 100,
          startedAt: DateTime.now(),
          completed: false,
          distractionsCount: 3,
        ),
        FocusSession(
          id: '3',
          durationMinutes: 25,
          elapsedSeconds: 50,
          startedAt: DateTime.now(),
          completed: false,
          distractionsCount: 2,
        ),
        FocusSession(
          id: '4',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime.now(),
          completed: true,
          distractionsCount: 0,
        ),
      ];

      final abandoned =
          sessions.where((s) => !s.completed).length;
      final focusDriftRate = abandoned / sessions.length;

      expect(focusDriftRate > 0.30, true);
    });

    test('Distraction average rate', () {
      final sessions = [
        FocusSession(
          id: '1',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime.now(),
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '2',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime.now(),
          completed: true,
          distractionsCount: 2,
        ),
        FocusSession(
          id: '3',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime.now(),
          completed: true,
          distractionsCount: 1,
        ),
      ];

      final totalDistractions =
          sessions.fold<int>(0, (sum, s) => sum + s.distractionsCount);
      final avgDistractionRate = totalDistractions / sessions.length;

      expect(avgDistractionRate, 1.0); // Average 1 distraction per session
    });

    test('Best focus hour calculation (hour with best completion rate)', () {
      final sessions = [
        FocusSession(
          id: '1',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime(2024, 1, 1, 9, 0), // 9 AM
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '2',
          durationMinutes: 25,
          elapsedSeconds: 1500,
          startedAt: DateTime(2024, 1, 2, 9, 30), // 9 AM
          completed: true,
          distractionsCount: 0,
        ),
        FocusSession(
          id: '3',
          durationMinutes: 25,
          elapsedSeconds: 200,
          startedAt: DateTime(2024, 1, 1, 14, 0), // 2 PM
          completed: false,
          distractionsCount: 2,
        ),
      ];

      // Group by hour
      final groupedByHour = <int, List<FocusSession>>{};
      for (var session in sessions) {
        final hour = session.startedAt.hour;
        if (!groupedByHour.containsKey(hour)) {
          groupedByHour[hour] = [];
        }
        groupedByHour[hour]!.add(session);
      }

      // Find best hour (highest completion rate)
      int? bestHour;
      double bestRate = 0;
      groupedByHour.forEach((hour, hourSessions) {
        final completionRate =
            hourSessions.where((s) => s.completed).length / hourSessions.length;
        if (completionRate > bestRate) {
          bestRate = completionRate;
          bestHour = hour;
        }
      });

      expect(bestHour, 9); // 9 AM has 100% completion rate
      expect(bestRate, 1.0);
    });
  });
}
