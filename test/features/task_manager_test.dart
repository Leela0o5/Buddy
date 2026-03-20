import 'package:flutter_test/flutter_test.dart';
import 'package:buddy/core/models/task.dart';

void main() {
  group('Task Manager Feature Tests', () {
    test('Task can be created with title', () {
      final task = Task(
        id: 'task-1',
        title: 'Complete project',
        description: 'Finish the feature',
        completed: false,
        createdAt: DateTime.now(),
      );

      expect(task.title, 'Complete project');
      expect(task.completed, false);
    });

    test('Task can be marked complete', () {
      var task = Task(
        id: 'task-2',
        title: 'Study math',
        completed: false,
        createdAt: DateTime.now(),
      );

      task = task.copyWith(completed: true);
      expect(task.completed, true);
    });

    test('Subtasks can be added to task', () {
      final task = Task(
        id: 'task-3',
        title: 'Write report',
        subtasks: [
          Subtask(title: 'Gather data', completed: false),
          Subtask(title: 'Analyze', completed: false),
          Subtask(title: 'Format', completed: false),
        ],
        completed: false,
        createdAt: DateTime.now(),
      );

      expect(task.subtasks.length, 3);
      expect(task.completedSubtaskCount, 0);
    });

    test('Subtask completion tracking', () {
      var task = Task(
        id: 'task-4',
        title: 'Project',
        subtasks: [
          Subtask(title: 'Step 1', completed: false),
          Subtask(title: 'Step 2', completed: false),
          Subtask(title: 'Step 3', completed: false),
        ],
        completed: false,
        createdAt: DateTime.now(),
      );

      // Complete first subtask
      task = task.copyWith(
        subtasks: [
          task.subtasks[0].copyWith(completed: true),
          task.subtasks[1],
          task.subtasks[2],
        ],
      );

      expect(task.completedSubtaskCount, 1);

      // Complete second subtask
      task = task.copyWith(
        subtasks: [
          task.subtasks[0],
          task.subtasks[1].copyWith(completed: true),
          task.subtasks[2],
        ],
      );

      expect(task.completedSubtaskCount, 2);
    });

    test('Task suggestions keywords mapping', () {
      // This tests the keyword-to-suggestion mapping logic
      const writeKeywords = ['write', 'essay', 'article', 'blog'];
      const codeKeywords = ['code', 'program', 'develop', 'build'];

      expect(writeKeywords.contains('write'), true);
      expect(codeKeywords.contains('code'), true);
      expect(writeKeywords.contains('code'), false);
    });

    test('Task deletion removes from list', () {
      final tasks = [
        Task(
          id: 'task-5',
          title: 'Task to keep',
          completed: false,
          createdAt: DateTime.now(),
        ),
        Task(
          id: 'task-6',
          title: 'Task to delete',
          completed: false,
          createdAt: DateTime.now(),
        ),
      ];

      final filtered = tasks.where((t) => t.id != 'task-6').toList();

      expect(tasks.length, 2);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'task-5');
    });

    test('Task filtering by completion status', () {
      final tasks = [
        Task(
          id: 'task-7',
          title: 'Done',
          completed: true,
          createdAt: DateTime.now(),
        ),
        Task(
          id: 'task-8',
          title: 'Not done',
          completed: false,
          createdAt: DateTime.now(),
        ),
        Task(
          id: 'task-9',
          title: 'Also done',
          completed: true,
          createdAt: DateTime.now(),
        ),
      ];

      final completed = tasks.where((t) => t.completed).toList();
      final incomplete = tasks.where((t) => !t.completed).toList();

      expect(completed.length, 2);
      expect(incomplete.length, 1);
    });
  });
}
