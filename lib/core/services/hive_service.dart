import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../config/constants.dart';

// Service to initialize and manage Hive database
class HiveService {
  static final HiveService _instance = HiveService._internal();

  factory HiveService() => _instance;

  HiveService._internal();

  // Initialize Hive and register all adapters
  // Must be called in main() before app starts
  Future<void> initialize() async {
    try {
      // Initialize Hive for Flutter (handles app documents directory)
      await Hive.initFlutter();


      // Open all boxes
      await _openBoxes();

      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Open all storage boxes
  Future<void> _openBoxes() async {
    try {
      await Hive.openBox<dynamic>(AppConstants.focusSessionsBox);
      await Hive.openBox<dynamic>(AppConstants.tasksBox);
      await Hive.openBox<dynamic>(AppConstants.reflectionsBox);
      await Hive.openBox<dynamic>(AppConstants.preferencesBox);

      debugPrint('All Hive boxes opened');
    } catch (e) {
      debugPrint('Error opening boxes: $e');
      rethrow;
    }
  }

  /// Get a box by name
  Box<dynamic> getBox(String boxName) {
    try {
      return Hive.box(boxName);
    } catch (e) {
      debugPrint('Error getting box $boxName: $e');
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> closeAllBoxes() async {
    try {
      await Hive.close();
      debugPrint('All Hive boxes closed');
    } catch (e) {
      debugPrint('Error closing boxes: $e');
    }
  }

  /// Clear all data (useful for testing/reset)
  Future<void> clearAllBoxes() async {
    try {
      final focusSessions = getBox(AppConstants.focusSessionsBox);
      final tasks = getBox(AppConstants.tasksBox);
      final reflections = getBox(AppConstants.reflectionsBox);
      final prefs = getBox(AppConstants.preferencesBox);

      await Future.wait([
        focusSessions.clear(),
        tasks.clear(),
        reflections.clear(),
        prefs.clear(),
      ]);

      debugPrint('All boxes cleared');
    } catch (e) {
      debugPrint('Error clearing boxes: $e');
    }
  }
}