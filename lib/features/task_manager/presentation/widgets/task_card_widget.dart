import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/task.dart';
import '../state/task_provider.dart';

// Card widget for displaying a single task
class TaskCardWidget extends ConsumerWidget {
  final Task task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCardWidget({
    Key? key,
    required this.task,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Checkbox(
          value: task.completed,
          onChanged: (_) {
            ref.read(toggleTaskCompletionProvider(task));
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration:
                          task.completed ? TextDecoration.lineThrough : null,
                    ),
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: onEdit,
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Task?'),
                        content: Text(
                          'Are you sure you want to delete "${task.title}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(deleteTaskProvider(task.id));
                              Navigator.pop(context);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.delete, size: 18),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              task.subtasks.isNotEmpty
                  ? '${task.completedSubtaskCount}/${task.subtasks.length} subtasks'
                  : 'No subtasks',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: task.subtasks.isNotEmpty
                        ? null
                        : Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ),
        children: [
          if (task.subtasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: task.subtaskProgress,
                  minHeight: 6,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          if ((task.description ?? '').trim().isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          if (task.subtasks.isNotEmpty)
            ...task.subtasks.map(
              (subtask) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  subtask.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: subtask.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                value: subtask.completed,
                onChanged: (_) {
                  ref.read(
                    toggleSubtaskProvider(
                      SubtaskToggleArgs(task: task, subtaskId: subtask.id),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}