import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/task.dart';
import '../../../../config/constants.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../state/task_provider.dart';

// Screen to add a new task
class AddTaskScreen extends ConsumerStatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({
    Key? key,
    this.taskToEdit,
  }) : super(key: key);

  @override
  ConsumerState<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends ConsumerState<AddTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<Subtask> _subtasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.taskToEdit?.description ?? '');
    _subtasks = widget.taskToEdit?.subtasks ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Suggest subtasks based on title keywords
  List<String> _suggestSubtasks(String title) {
    final titleLower = title.toLowerCase();

    if (titleLower.contains('write') || titleLower.contains('report')) {
      return [
        'Open document',
        'Write title',
        'First paragraph',
        'Review and edit',
      ];
    } else if (titleLower.contains('email') || titleLower.contains('message')) {
      return [
        'Draft message',
        'Add recipient',
        'Review',
        'Send',
      ];
    } else if (titleLower.contains('meeting') || titleLower.contains('call')) {
      return [
        'Schedule time',
        'Prepare materials',
        'Join call',
        'Follow up',
      ];
    } else if (titleLower.contains('code') || titleLower.contains('feature')) {
      return [
        'Create branch',
        'Understand requirements',
        'Write code',
        'Test',
        'Create PR',
      ];
    } else {
      return [
        'Start',
        'Work on it',
        'Review',
        'Complete',
      ];
    }
  }

  void _showSubtaskSuggestions() {
    final suggestions = _suggestSubtasks(_titleController.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suggested Subtasks'),
        content: SingleChildScrollView(
          child: Column(
            children: suggestions
                .map(
                  (suggestion) => CheckboxListTile(
                    value: _subtasks.any((s) => s.title == suggestion),
                    title: Text(suggestion),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _subtasks.add(Subtask(title: suggestion));
                        } else {
                          _subtasks.removeWhere((s) => s.title == suggestion);
                        }
                      });
                      Navigator.pop(context);
                      _showSubtaskSuggestions();
                    },
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _addCustomSubtask() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Subtask title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _subtasks.add(Subtask(title: controller.text));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveTask() async {
    final messenger = ScaffoldMessenger.of(context);

    if (_titleController.text.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newTask = Task(
      id: widget.taskToEdit?.id,
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      subtasks: _subtasks,
      completed: widget.taskToEdit?.completed ?? false,
    );

    try {
      await ref.read(addTaskProvider(newTask).future);
      if (!mounted) return;

      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Task saved successfully!')),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: widget.taskToEdit != null ? 'Edit Task' : 'New Task',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'What do you need to do?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Description field
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Subtasks section
            Text(
              'Subtasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            // Subtask list
            if (_subtasks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No subtasks yet. Break this task into smaller steps!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subtasks.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(_subtasks[index].title),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() => _subtasks.removeAt(index));
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Add subtask buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showSubtaskSuggestions,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Suggestions'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addCustomSubtask,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: AppConstants.largeButtonHeight,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveTask,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}