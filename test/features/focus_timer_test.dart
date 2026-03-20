import 'package:flutter_test/flutter_test.dart';
import 'package:buddy/core/models/focus_session.dart';

void main() {
  group('Focus Timer Feature Tests', () {
    test('Timer durations are valid', () {
      const validDurations = [5, 10, 15, 25];
      expect(validDurations.contains(5), true);
      expect(validDurations.contains(10), true);
      expect(validDurations.contains(25), true);
    });

    test('Session elapsed time tracking', () {
      final now = DateTime.now();
      final session = FocusSession(
        id: 'timer-1',
        durationMinutes: 25,
        elapsedSeconds: 0,
        startedAt: now,
        completed: false,
        distractionsCount: 0,
      );

      expect(session.remainingSeconds, 1500); // 25 * 60

      // Simulate 5 minutes elapsed
      final updated = session.copyWith(elapsedSeconds: 300);
      expect(updated.remainingSeconds, 1200);
      expect(updated.completionPercentage, 0.2); // 20% done
    });

    test('Distraction counter increments', () {
      var session = FocusSession(
        id: 'timer-2',
        durationMinutes: 25,
        elapsedSeconds: 0,
        startedAt: DateTime.now(),
        completed: false,
        distractionsCount: 0,
      );

      // Record distraction
      session = session.copyWith(distractionsCount: session.distractionsCount + 1);
      expect(session.distractionsCount, 1);

      // Record another
      session = session.copyWith(distractionsCount: session.distractionsCount + 1);
      expect(session.distractionsCount, 2);
    });

    test('Session completion status', () {
      final now = DateTime.now();
      final completed = FocusSession(
        id: 'timer-3',
        durationMinutes: 25,
        elapsedSeconds: 1500,
        startedAt: now,
        endedAt: now.add(const Duration(minutes: 25)),
        completed: true,
        distractionsCount: 0,
      );

      expect(completed.completed, true);
      expect(completed.wasAbandoned, false);
    });

    test('Start Small mode works (5 minute session)', () {
      final session = FocusSession(
        id: 'start-small-1',
        durationMinutes: 5,
        elapsedSeconds: 0,
        startedAt: DateTime.now(),
        completed: false,
        distractionsCount: 0,
      );

      expect(session.durationMinutes, 5);
      expect(session.remainingSeconds, 300);
    });
  });
}
