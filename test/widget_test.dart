import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buddy/app.dart';
import 'package:buddy/core/models/energy_log.dart';
import 'package:buddy/core/models/focus_session.dart';
import 'package:buddy/core/models/task.dart';
import 'package:buddy/core/models/user_preferences.dart';
import 'package:buddy/core/services/storage_service.dart';
import 'package:buddy/features/focus_timer/presentation/state/timer_provider.dart'
    as timer_state;
import 'package:buddy/features/reflection/presentation/state/reflection_provider.dart'
    as reflection_state;
import 'package:buddy/features/settings/presentation/state/preferences_provider.dart'
    as settings_state;
import 'package:buddy/features/task_manager/presentation/state/task_provider.dart'
    as task_state;

class _FakeStorageService implements StorageService {
  final Map<String, FocusSession> _sessions = {};
  final Map<String, Task> _tasks = {};
  final Map<String, EnergyLog> _logs = {};
  UserPreferences? _prefs;

  @override
  Future<void> saveFocusSession(FocusSession session) async {
    _sessions[session.id] = session;
  }

  @override
  Future<FocusSession?> getFocusSession(String id) async => _sessions[id];

  @override
  Future<List<FocusSession>> getAllFocusSessions() async =>
      _sessions.values.toList();

  @override
  Future<void> deleteFocusSession(String id) async {
    _sessions.remove(id);
  }

  @override
  Future<void> saveTask(Task task) async {
    _tasks[task.id] = task;
  }

  @override
  Future<Task?> getTask(String id) async => _tasks[id];

  @override
  Future<List<Task>> getAllTasks() async => _tasks.values.toList();

  @override
  Future<void> deleteTask(String id) async {
    _tasks.remove(id);
  }

  @override
  Future<void> saveEnergyLog(EnergyLog log) async {
    _logs[log.id] = log;
  }

  @override
  Future<EnergyLog?> getEnergyLog(String id) async => _logs[id];

  @override
  Future<List<EnergyLog>> getAllEnergyLogs() async => _logs.values.toList();

  @override
  Future<List<EnergyLog>> getEnergyLogsForSession(String sessionId) async {
    return _logs.values.where((log) => log.sessionId == sessionId).toList();
  }

  @override
  Future<void> deleteEnergyLog(String id) async {
    _logs.remove(id);
  }

  @override
  Future<void> savePreferences(UserPreferences prefs) async {
    _prefs = prefs;
  }

  @override
  Future<UserPreferences?> getPreferences() async => _prefs;

  @override
  Future<void> clearAll() async {
    _sessions.clear();
    _tasks.clear();
    _logs.clear();
    _prefs = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App initializes without errors', (WidgetTester tester) async {
    final fakeStorage = _FakeStorageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          timer_state.storageServiceProvider.overrideWithValue(fakeStorage),
          reflection_state.storageServiceProvider.overrideWithValue(fakeStorage),
          settings_state.storageServiceProvider.overrideWithValue(fakeStorage),
          task_state.taskStorageServiceProvider.overrideWithValue(fakeStorage),
        ],
        child: const Buddy(),
      ),
    );
    expect(find.byType(Buddy), findsOneWidget);
  });
}