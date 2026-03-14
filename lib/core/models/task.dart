import 'package:uuid/uuid.dart';

// A subtask within a larger task
class Subtask {
  final String id;
  final String title;
  final bool completed;
  final DateTime createdAt;

  Subtask({
    String? id,
    required this.title,
    bool? completed,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        completed = completed ?? false,
        createdAt = createdAt ?? DateTime.now();

  Subtask copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Domain entity for a task
class Task {
  final String id;
  final String title;
  final String? description;
  final List<Subtask> subtasks;
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? associatedSessionId; // Link to focus session if started from task

  Task({
    String? id,
    required this.title,
    this.description,
    List<Subtask>? subtasks,
    bool? completed,
    DateTime? createdAt,
    this.completedAt,
    this.associatedSessionId,
  })  : id = id ?? const Uuid().v4(),
        subtasks = subtasks ?? [],
        completed = completed ?? false,
        createdAt = createdAt ?? DateTime.now();

  // How many subtasks are done
  int get completedSubtaskCount =>
      subtasks.where((s) => s.completed).length;

  // Progress percentage
  double get subtaskProgress =>
      subtasks.isEmpty ? 0.0 : completedSubtaskCount / subtasks.length;

  // Add a subtask
  Task addSubtask(Subtask subtask) {
    return copyWith(subtasks: [...subtasks, subtask]);
  }

  // Toggle subtask completion
  Task toggleSubtask(String subtaskId) {
    final updated = subtasks.map((s) {
      if (s.id == subtaskId) {
        return s.copyWith(completed: !s.completed);
      }
      return s;
    }).toList();
    return copyWith(subtasks: updated);
  }

  // Copy with new values
  Task copyWith({
    String? id,
    String? title,
    String? description,
    List<Subtask>? subtasks,
    bool? completed,
    DateTime? createdAt,
    DateTime? completedAt,
    int? associatedSessionId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subtasks: subtasks ?? this.subtasks,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      associatedSessionId: associatedSessionId ?? this.associatedSessionId,
    );
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, subtasks: ${subtasks.length}, completed: $completed)';
}