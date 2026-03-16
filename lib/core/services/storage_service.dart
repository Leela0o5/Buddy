import '../models/focus_session.dart';
import '../models/task.dart';
import '../models/energy_log.dart';
import '../models/user_preferences.dart';

// Abstract storage interface
// Implementation uses Hive 
abstract class StorageService {
  // Focus Sessions
  Future<void> saveFocusSession(FocusSession session);
  Future<FocusSession?> getFocusSession(String id);
  Future<List<FocusSession>> getAllFocusSessions();
  Future<void> deleteFocusSession(String id);

  // Tasks
  Future<void> saveTask(Task task);
  Future<Task?> getTask(String id);
  Future<List<Task>> getAllTasks();
  Future<void> deleteTask(String id);

  // Energy Logs
  Future<void> saveEnergyLog(EnergyLog log);
  Future<EnergyLog?> getEnergyLog(String id);
  Future<List<EnergyLog>> getAllEnergyLogs();
  Future<List<EnergyLog>> getEnergyLogsForSession(String sessionId);

  // Preferences
  Future<void> savePreferences(UserPreferences prefs);
  Future<UserPreferences?> getPreferences();

  // Bulk operations
  Future<void> clearAll();
}