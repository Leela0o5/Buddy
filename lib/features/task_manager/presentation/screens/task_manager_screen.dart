import 'package:flutter/material.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';

// Task management screen
class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({Key? key}) : super(key: key);

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  // Placeholder for tasks list - this will be replaced with data in actual storage implementation.
  final List<Map<String, dynamic>> tasks = [];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: AppStrings.tasksTab,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add task screen coming soon...')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addTask),
      ),
      body: tasks.isEmpty ? _buildEmptyState(context) : _buildTaskList(context),
    );
  }

  // Empty state when no tasks
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noTasks,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  // Task list view
  Widget _buildTaskList(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(context, task);
      },
    );
  }

  // Individual task card
  Widget _buildTaskCard(BuildContext context, Map<String, dynamic> task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(value: false, onChanged: (_) {}),
        title: Text(task['title'] ?? 'Untitled'),
        subtitle: Text('${task['subtasks']?.length ?? 0} subtasks'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}