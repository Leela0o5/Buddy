import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/task.dart';
import '../../../../config/constants.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../state/task_provider.dart';
import '../widgets/subtask_suggestion_widget.dart';

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
              onChanged: (_) => setState(() {}),
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

            // AI Suggestions widget
            SubtaskSuggestionWidget(
              taskTitle: _titleController.text,
              selectedSubtasks: _subtasks,
              onSubtasksChanged: (updatedSubtasks) {
                setState(() {
                  _subtasks = updatedSubtasks;
                });
              },
            ),
            const SizedBox(height: 16),

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

            // Add custom subtask button
            OutlinedButton.icon(
              onPressed: _addCustomSubtask,
              icon: const Icon(Icons.add),
              label: const Text('Add Custom Subtask'),
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