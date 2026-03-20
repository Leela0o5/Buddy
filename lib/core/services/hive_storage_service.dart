import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/focus_session.dart';
import '../models/task.dart';
import '../models/energy_log.dart';
import '../models/user_preferences.dart';
import '../../config/constants.dart';
import 'storage_service.dart';
import 'hive_service.dart';

// Hive implementation of StorageService
// Converts domain models to or from JSON for storage
class HiveStorageService implements StorageService {
  final HiveService _hiveService;

  HiveStorageService({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService();

  // Convenience getters for boxes
  Box<dynamic> _getFocusSessionBox() =>
      _hiveService.getBox(AppConstants.focusSessionsBox);
  Box<dynamic> _getTaskBox() =>
      _hiveService.getBox(AppConstants.tasksBox);
  Box<dynamic> _getReflectionBox() =>
      _hiveService.getBox(AppConstants.reflectionsBox);
  Box<dynamic> _getPreferencesBox() =>
      _hiveService.getBox(AppConstants.preferencesBox);

  @override
  Future<void> saveFocusSession(FocusSession session) async {
    try {
      final box = _getFocusSessionBox();
      await box.put(session.id, _serializeFocusSession(session));
    } catch (e) {
      debugPrint('Error saving focus session: $e');
      rethrow;
    }
  }

  @override
  Future<FocusSession?> getFocusSession(String id) async {
    try {
      final box = _getFocusSessionBox();
      final data = box.get(id);
      return data != null ? _deserializeFocusSession(_asStringDynamicMap(data)) : null;
    } catch (e) {
      debugPrint('Error getting focus session: $e');
      return null;
    }
  }

  @override
  Future<List<FocusSession>> getAllFocusSessions() async {
    try {
      final box = _getFocusSessionBox();
      return box.values
          .map((data) => _deserializeFocusSession(_asStringDynamicMap(data)))
          .toList();
    } catch (e) {
      debugPrint('Error getting all focus sessions: $e');
      return [];
    }
  }

  @override
  Future<void> deleteFocusSession(String id) async {
    try {
      final box = _getFocusSessionBox();
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting focus session: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveTask(Task task) async {
    try {
      final box = _getTaskBox();
      await box.put(task.id, _serializeTask(task));
    } catch (e) {
      debugPrint('Error saving task: $e');
      rethrow;
    }
  }

  @override
  Future<Task?> getTask(String id) async {
    try {
      final box = _getTaskBox();
      final data = box.get(id);
      return data != null ? _deserializeTask(_asStringDynamicMap(data)) : null;
    } catch (e) {
      debugPrint('Error getting task: $e');
      return null;
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final box = _getTaskBox();
      return box.values
          .map((data) => _deserializeTask(_asStringDynamicMap(data)))
          .toList();
    } catch (e) {
      debugPrint('Error getting all tasks: $e');
      return [];
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      final box = _getTaskBox();
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveEnergyLog(EnergyLog log) async {
    try {
      final box = _getReflectionBox();
      await box.put(log.id, _serializeEnergyLog(log));
    } catch (e) {
      debugPrint('Error saving energy log: $e');
      rethrow;
    }
  }

  @override
  Future<EnergyLog?> getEnergyLog(String id) async {
    try {
      final box = _getReflectionBox();
      final data = box.get(id);
      return data != null ? _deserializeEnergyLog(_asStringDynamicMap(data)) : null;
    } catch (e) {
      debugPrint('Error getting energy log: $e');
      return null;
    }
  }

  @override
  Future<List<EnergyLog>> getAllEnergyLogs() async {
    try {
      final box = _getReflectionBox();
      return box.values
          .map((data) => _deserializeEnergyLog(_asStringDynamicMap(data)))
          .toList();
    } catch (e) {
      debugPrint('Error getting all energy logs: $e');
      return [];
    }
  }

  @override
  Future<List<EnergyLog>> getEnergyLogsForSession(String sessionId) async {
    try {
      final box = _getReflectionBox();
      final allLogs = box.values
          .map((data) => _deserializeEnergyLog(_asStringDynamicMap(data)))
          .toList();
      return allLogs.where((log) => log.sessionId == sessionId).toList();
    } catch (e) {
      debugPrint('Error getting energy logs for session: $e');
      return [];
    }
  }

  @override
  Future<void> deleteEnergyLog(String id) async {
    try {
      final box = _getReflectionBox();
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting energy log: $e');
      rethrow;
    }
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    try {
      final box = _getPreferencesBox();
      // Store as single entry with key 'user_prefs'
      await box.put('user_prefs', _serializePreferences(prefs));
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      rethrow;
    }
  }

  @override
  Future<UserPreferences?> getPreferences() async {
    try {
      final box = _getPreferencesBox();
      final data = box.get('user_prefs');
      return data != null ? _deserializePreferences(_asStringDynamicMap(data)) : null;
    } catch (e) {
      debugPrint('Error getting preferences: $e');
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _hiveService.clearAllBoxes();
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    }
  }

  // Convert domain models to JSON-compatible Maps for storage

  Map<String, dynamic> _asStringDynamicMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw.map(
        (key, value) => MapEntry(key.toString(), value),
      ));
    }
    throw StateError('Expected a Map but got ${raw.runtimeType}');
  }

  Map<String, dynamic> _serializeFocusSession(FocusSession session) {
    return {
      'id': session.id,
      'durationMinutes': session.durationMinutes,
      'elapsedSeconds': session.elapsedSeconds,
      'startedAt': session.startedAt.toIso8601String(),
      'endedAt': session.endedAt?.toIso8601String(),
      'completed': session.completed,
      'distractionsCount': session.distractionsCount,
      'notes': session.notes,
    };
  }

  FocusSession _deserializeFocusSession(Map<String, dynamic> data) {
    return FocusSession(
      id: data['id'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      elapsedSeconds: data['elapsedSeconds'] ?? 0,
      startedAt: DateTime.parse(data['startedAt'] ?? DateTime.now().toIso8601String()),
      endedAt: data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
      completed: data['completed'] ?? false,
      distractionsCount: data['distractionsCount'] ?? 0,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> _serializeTask(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'subtasks': task.subtasks
          .map((s) => {
                'id': s.id,
                'title': s.title,
                'completed': s.completed,
                'createdAt': s.createdAt.toIso8601String(),
              })
          .toList(),
      'completed': task.completed,
      'createdAt': task.createdAt.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
      'associatedSessionId': task.associatedSessionId,
    };
  }

  Task _deserializeTask(Map<String, dynamic> data) {
    final subtasksData = (data['subtasks'] as List<dynamic>? ?? []);
    final subtasks = subtasksData
        .map((s) {
          final subtask = _asStringDynamicMap(s);
          return Subtask(
              id: subtask['id'] ?? '',
              title: subtask['title'] ?? '',
              completed: subtask['completed'] ?? false,
              createdAt: DateTime.parse(
                  subtask['createdAt'] ?? DateTime.now().toIso8601String()),
            );
        })
        .toList();

    return Task(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      subtasks: subtasks,
      completed: data['completed'] ?? false,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
      associatedSessionId: data['associatedSessionId'],
    );
  }

  Map<String, dynamic> _serializeEnergyLog(EnergyLog log) {
    return {
      'id': log.id,
      'sessionId': log.sessionId,
      'energyLevel': log.energyLevel.name,
      'reflectionNotes': log.reflectionNotes,
      'createdAt': log.createdAt.toIso8601String(),
    };
  }

  EnergyLog _deserializeEnergyLog(Map<String, dynamic> data) {
    return EnergyLog(
      id: data['id'] ?? '',
      sessionId: data['sessionId'] ?? '',
      energyLevel: EnergyLevel.values.firstWhere(
        (e) => e.name == data['energyLevel'],
        orElse: () => EnergyLevel.medium,
      ),
      reflectionNotes: data['reflectionNotes'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> _serializePreferences(UserPreferences prefs) {
    return {
      'darkModeEnabled': prefs.darkModeEnabled,
      'vibrationEnabled': prefs.vibrationEnabled,
      'soundEnabled': prefs.soundEnabled,
      'notificationsEnabled': prefs.notificationsEnabled,
      'notificationHour': prefs.notificationHour,
      'lastUpdated': prefs.lastUpdated.toIso8601String(),
    };
  }

  UserPreferences _deserializePreferences(Map<String, dynamic> data) {
    return UserPreferences(
      darkModeEnabled: data['darkModeEnabled'] ?? false,
      vibrationEnabled: data['vibrationEnabled'] ?? true,
      soundEnabled: data['soundEnabled'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      notificationHour: data['notificationHour'] ?? 9,
      lastUpdated: DateTime.parse(data['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }
}