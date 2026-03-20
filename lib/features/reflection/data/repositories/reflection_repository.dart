import '../../../../core/models/energy_log.dart';
import '../../../../core/services/storage_service.dart';

// Repository for reflection journal and energy log data
class ReflectionRepository {
  final StorageService storageService;

  ReflectionRepository({required this.storageService});

  // Save reflection energy log
  Future<void> saveEnergyLog(EnergyLog energyLog) async {
    await storageService.saveEnergyLog(energyLog);
  }

  // Get energy log by ID
  Future<EnergyLog?> getEnergyLogById(String id) async {
    return await storageService.getEnergyLog(id);
  }

  // Get all energy logs
  Future<List<EnergyLog>> getAllEnergyLogs() async {
    return await storageService.getAllEnergyLogs();
  }

  // Get energy logs for a specific session
  Future<EnergyLog?> getLogBySessionId(String sessionId) async {
    final logs = await storageService.getEnergyLogsForSession(sessionId);
    return logs.isEmpty ? null : logs.first;
  }

  // Delete energy log
  Future<void> deleteEnergyLog(String id) async {
    await storageService.deleteEnergyLog(id);
  }

  // Get today's energy logs
  Future<List<EnergyLog>> getTodayEnergyLogs() async {
    final allLogs = await getAllEnergyLogs();
    final today = DateTime.now();

    return allLogs
        .where((log) =>
            log.createdAt.year == today.year &&
            log.createdAt.month == today.month &&
            log.createdAt.day == today.day)
        .toList();
  }

  // Get average energy level for today (0=low, 1=medium, 2=high)
  Future<double> getTodayAverageEnergyLevel() async {
    final todayLogs = await getTodayEnergyLogs();
    if (todayLogs.isEmpty) return 0;

    final sum = todayLogs.fold<int>(0, (total, log) {
      switch (log.energyLevel) {
        case EnergyLevel.low:
          return total + 0;
        case EnergyLevel.medium:
          return total + 1;
        case EnergyLevel.high:
          return total + 2;
      }
    });

    return sum / todayLogs.length;
  }
}
