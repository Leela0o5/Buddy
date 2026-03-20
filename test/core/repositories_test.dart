import 'package:flutter_test/flutter_test.dart';
import 'package:buddy/core/models/focus_session.dart';
import 'package:buddy/core/models/task.dart';

void main() {
  group('Repository Tests', () {
    group('FocusSessionRepository', () {
      test('Session model creation', () {
        final session = FocusSession(
          id: 'test-1',
          durationMinutes: 25,
          elapsedSeconds: 0,
          startedAt: DateTime.now(),
          completed: false,
          distractionsCount: 0,
        );

        expect(session.id, 'test-1');
        expect(session.durationMinutes, 25);
        expect(session.completed, false);
        expect(session.remainingSeconds, 25 * 60);
      });

      test('Session completion percentage calculation', () {
        final session = FocusSession(
          id: 'test-2',
          durationMinutes: 25,
          elapsedSeconds: 750, // 12.5 minutes
          startedAt: DateTime.now(),
          completed: false,
          distractionsCount: 0,
        );

        expect(session.completionPercentage, 0.5); // 50%
      });

      test('Session abandoned detection', () {
        final now = DateTime.now();
        final completedSession = FocusSession(
          id: 'completed',
          durationMinutes: 25,
          elapsedSeconds: 1500, // Full 25 min
          startedAt: now,
          endedAt: now.add(const Duration(minutes: 25)),
          completed: true,
          distractionsCount: 0,
        );

        final abandonedSession = FocusSession(
          id: 'abandoned',
          durationMinutes: 25,
          elapsedSeconds: 300, // Only 5 min
          startedAt: now,
          endedAt: now.add(const Duration(minutes: 5)),
          completed: false,
          distractionsCount: 2,
        );

        expect(completedSession.wasAbandoned, false);
        expect(abandonedSession.wasAbandoned, true);
      });
    });

    group('TaskRepository', () {
      test('Task creation with subtasks', () {
        final task = Task(
          id: 'task-1',
          title: 'Write article',
          description: 'Blog post about ADHD',
          subtasks: [
            Subtask(title: 'Create outline', completed: false),
            Subtask(title: 'Write draft', completed: false),
          ],
          completed: false,
          createdAt: DateTime.now(),
        );

        expect(task.title, 'Write article');
        expect(task.subtasks.length, 2);
        expect(task.completedSubtaskCount, 0);
      });

      test('Subtask toggle', () {
        var task = Task(
          id: 'task-2',
          title: 'Study math',
          subtasks: [
            Subtask(title: 'Chapter 1', completed: false),
            Subtask(title: 'Chapter 2', completed: false),
          ],
          completed: false,
          createdAt: DateTime.now(),
        );

        // Toggle first subtask
        task = task.copyWith(
          subtasks: [
            task.subtasks[0].copyWith(completed: true),
            task.subtasks[1],
          ],
        );

        expect(task.completedSubtaskCount, 1);
      });

      test('Task copyWith preserves data', () {
        final now = DateTime.now();
        final task = Task(
          id: 'task-3',
          title: 'Original',
          description: 'Desc',
          completed: false,
          createdAt: now,
        );

        final updated = task.copyWith(
          title: 'Updated',
          completed: true,
        );

        expect(updated.id, task.id);
        expect(updated.title, 'Updated');
        expect(updated.completed, true);
        expect(updated.createdAt, now);
      });
    });
  });
}
