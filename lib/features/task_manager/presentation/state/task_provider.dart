import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/task.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/hive_storage_service.dart';
import '../../data/repositories/task_repository.dart';


// Storage service provider
final taskStorageServiceProvider = Provider<StorageService>((ref) {
  return HiveStorageService();
});

// Task repository provider
final taskRepositoryProvider = Provider((ref) {
  final storageService = ref.watch(taskStorageServiceProvider);
  return TaskRepository(storageService: storageService);
});

// Selected task filter (all, incomplete, completed)
final taskFilterProvider = StateProvider<String>((ref) => 'all');

// Currently selected task for editing
final selectedTaskProvider = StateProvider<Task?>((ref) => null);



// Get all tasks
final allTasksProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getAll();
});

// Get incomplete tasks
final incompleteTasksProvider =
    FutureProvider.autoDispose<List<Task>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getIncompleteTasks();
});

// Get completed tasks
final completedTasksProvider =
    FutureProvider.autoDispose<List<Task>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getCompletedTasks();
});

// Filtered tasks based on selected filter
final filteredTasksProvider =
    FutureProvider.autoDispose<List<Task>>((ref) async {
  final filter = ref.watch(taskFilterProvider);
  final repository = ref.watch(taskRepositoryProvider);

  switch (filter) {
    case 'incomplete':
      return repository.getIncompleteTasks();
    case 'completed':
      return repository.getCompletedTasks();
    default:
      return repository.getAll();
  }
});

// Add new task
final addTaskProvider =
    FutureProvider.family.autoDispose<void, Task>((ref, task) async {
  final repository = ref.watch(taskRepositoryProvider);
  await repository.save(task);
  
  // Invalidate cache to refresh UI
  ref.invalidate(filteredTasksProvider);
  ref.invalidate(allTasksProvider);
});

// Delete task
final deleteTaskProvider =
    FutureProvider.family.autoDispose<void, String>((ref, taskId) async {
  final repository = ref.watch(taskRepositoryProvider);
  await repository.delete(taskId);
  
  // Invalidate cache
  ref.invalidate(filteredTasksProvider);
  ref.invalidate(allTasksProvider);
});

// Toggle task completion
final toggleTaskCompletionProvider =
    FutureProvider.family.autoDispose<void, Task>((ref, task) async {
  final repository = ref.watch(taskRepositoryProvider);
  await repository.toggleCompletion(task);
  
  // Invalidate cache
  ref.invalidate(filteredTasksProvider);
  ref.invalidate(allTasksProvider);
});

// Toggle subtask completion
final toggleSubtaskProvider = FutureProvider.family.autoDispose<void, SubtaskToggleArgs>((ref, args) async {
  final repository = ref.watch(taskRepositoryProvider);
  await repository.toggleSubtask(args.task, args.subtaskId);
  
  // Invalidate cache
  ref.invalidate(filteredTasksProvider);
  ref.invalidate(allTasksProvider);
});

// Arguments for toggling subtask
class SubtaskToggleArgs {
  final Task task;
  final String subtaskId;

  SubtaskToggleArgs({
    required this.task,
    required this.subtaskId,
  });
}