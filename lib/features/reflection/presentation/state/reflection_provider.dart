import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/energy_log.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/hive_storage_service.dart';
import '../../data/repositories/reflection_repository.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return HiveStorageService();
});

// Reflection repository provider
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  return ReflectionRepository(
    storageService: ref.watch(storageServiceProvider),
  );
});

// All energy logs provider
final allEnergyLogsProvider = FutureProvider<List<EnergyLog>>((ref) async {
  final repository = ref.watch(reflectionRepositoryProvider);
  return repository.getAllEnergyLogs();
});

// Today's energy logs provider
final todayEnergyLogsProvider = FutureProvider<List<EnergyLog>>((ref) async {
  final repository = ref.watch(reflectionRepositoryProvider);
  return repository.getTodayEnergyLogs();
});

// Today's average energy level provider
final todayAverageEnergyProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(reflectionRepositoryProvider);
  return repository.getTodayAverageEnergyLevel();
});

// Energy log for specific session
final sessionEnergyLogProvider =
    FutureProvider.family<EnergyLog?, String>((ref, sessionId) async {
  final repository = ref.watch(reflectionRepositoryProvider);
  return repository.getLogBySessionId(sessionId);
});

// Save energy log provider
final saveEnergyLogProvider = FutureProvider.family<void, EnergyLog>((ref, energyLog) async {
  final repository = ref.watch(reflectionRepositoryProvider);
  await repository.saveEnergyLog(energyLog);
  // Invalidate caches to refresh UI
  ref.invalidate(allEnergyLogsProvider);
  ref.invalidate(todayEnergyLogsProvider);
  ref.invalidate(todayAverageEnergyProvider);
  ref.invalidate(sessionEnergyLogProvider(energyLog.sessionId));
});

// Delete energy log provider
final deleteEnergyLogProvider = FutureProvider.family<void, String>((ref, id) async {
  final repository = ref.watch(reflectionRepositoryProvider);
  await repository.deleteEnergyLog(id);
  // Invalidate caches
  ref.invalidate(allEnergyLogsProvider);
  ref.invalidate(todayEnergyLogsProvider);
  ref.invalidate(todayAverageEnergyProvider);
});
