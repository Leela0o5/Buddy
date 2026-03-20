import 'package:flutter/foundation.dart';
import '../../../../core/models/task.dart';
import '../../../../core/services/storage_service.dart';

// Repository for task CRUD operations
class TaskRepository {
  final StorageService _storageService;

  TaskRepository({required StorageService storageService})
      : _storageService = storageService;

  // Save a task
  Future<void> save(Task task) async {
    try {
      await _storageService.saveTask(task);
      debugPrint('Task saved: ${task.title}');
    } catch (e) {
      debugPrint('Error saving task: $e');
      rethrow;
    }
  }

  // Get task by ID
  Future<Task?> getById(String id) async {
    try {
      return await _storageService.getTask(id);
    } catch (e) {
      rethrow;
    }
  }

  // Get all tasks
  Future<List<Task>> getAll() async {
    try {
      final tasks = await _storageService.getAllTasks();
      // Sort by created date (newest first)
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      rethrow;
    }
  }

  // Get incomplete tasks
  Future<List<Task>> getIncompleteTasks() async {
    try {
      final all = await getAll();
      return all.where((task) => !task.completed).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get completed tasks
  Future<List<Task>> getCompletedTasks() async {
    try {
      final all = await getAll();
      return all.where((task) => task.completed).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Delete task
  Future<void> delete(String id) async {
    try {
      await _storageService.deleteTask(id);
      debugPrint('Task deleted: $id');
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  // Toggle task completion
  Future<void> toggleCompletion(Task task) async {
    try {
      final nextCompleted = !task.completed;
      final updatedSubtasks = task.subtasks
          .map((subtask) => subtask.copyWith(completed: nextCompleted))
          .toList();

      final updated = task.copyWith(
        subtasks: updatedSubtasks,
        completed: nextCompleted,
        completedAt: nextCompleted ? DateTime.now() : null,
      );
      await save(updated);
    } catch (e) {
      rethrow;
    }
  }

  // Toggle subtask completion
  Future<void> toggleSubtask(Task task, String subtaskId) async {
    try {
      final toggled = task.toggleSubtask(subtaskId);
      final allDone =
          toggled.subtasks.isNotEmpty && toggled.subtasks.every((s) => s.completed);

      final updated = toggled.copyWith(
        completed: allDone,
        completedAt: allDone ? DateTime.now() : null,
      );
      await save(updated);
    } catch (e) {
      rethrow;
    }
  }
}