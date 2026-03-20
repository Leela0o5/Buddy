import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';
import '../../../../core/models/task.dart';
import '../widgets/task_card_widget.dart';
import '../state/task_provider.dart';
import 'add_task_screen.dart';

class TaskManagerScreen extends ConsumerWidget {
  const TaskManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskFilterProvider);
    final tasksAsync = ref.watch(filteredTasksProvider);

    return BaseScaffold(
      title: AppStrings.tasksTab,
      isScrollable: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addTask),
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(context, ref, filter),
          const SizedBox(height: 16),
          
          // Task list or empty state
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTaskList(context, tasks),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Filter tabs
  Widget _buildFilterTabs(
    BuildContext context,
    WidgetRef ref,
    String currentFilter,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(context, ref, 'all', 'All', currentFilter),
          const SizedBox(width: 8),
          _buildFilterChip(context, ref, 'incomplete', 'To Do', currentFilter),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            ref,
            'completed',
            'Done',
            currentFilter,
          ),
        ],
      ),
    );
  }

  // Individual filter chip
  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String filterValue,
    String label,
    String currentFilter,
  ) {
    final isSelected = currentFilter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(taskFilterProvider.notifier).state = filterValue;
      },
    );
  }

  // Empty state
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

  // Task list
  Widget _buildTaskList(BuildContext context, List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskCardWidget(
        task: tasks[index],
        onEdit: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(taskToEdit: tasks[index]),
            ),
          );
        },
        onDelete: () {
          // Handled in TaskCardWidget
        },
      ),
    );
  }
}