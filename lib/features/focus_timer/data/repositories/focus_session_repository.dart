import '../../../../core/models/focus_session.dart';
import '../../../../core/services/storage_service.dart';

// Repository for focus session CRUD operations
// Acts as a bridge between domain and data layers
class FocusSessionRepository {
  final StorageService _storageService;

  FocusSessionRepository({required StorageService storageService})
      : _storageService = storageService;

  // Save a focus session
  Future<void> save(FocusSession session) async {
    try {
      await _storageService.saveFocusSession(session);
    } catch (e) {
      rethrow;
    }
  }

  // Get session by ID
  Future<FocusSession?> getById(String id) async {
    try {
      return await _storageService.getFocusSession(id);
    } catch (e) {
      rethrow;
    }
  }

  // Get all sessions
  Future<List<FocusSession>> getAll() async {
    try {
      return await _storageService.getAllFocusSessions();
    } catch (e) {
      rethrow;
    }
  }

  // Get today's sessions
  Future<List<FocusSession>> getTodaySessions() async {
    try {
      final all = await _storageService.getAllFocusSessions();
      final today = DateTime.now();
      return all.where((session) {
        return session.startedAt.year == today.year &&
            session.startedAt.month == today.month &&
            session.startedAt.day == today.day;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Calculate current streak
  Future<int> getCurrentStreak() async {
    try {
      final all = await _storageService.getAllFocusSessions();
      if (all.isEmpty) return 0;

      // Sort by date descending
      final sorted = all..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      int streak = 0;
      DateTime? lastDate;

      for (final session in sorted) {
        if (!session.completed) continue; // Count only completed sessions

        final sessionDate = DateTime(
          session.startedAt.year,
          session.startedAt.month,
          session.startedAt.day,
        );

        if (lastDate == null) {
          streak = 1;
          lastDate = sessionDate;
        } else {
          final expectedDate = lastDate.subtract(const Duration(days: 1));
          if (sessionDate == expectedDate) {
            streak++;
            lastDate = sessionDate;
          } else {
            break; // Streak broken
          }
        }
      }

      return streak;
    } catch (e) {
      rethrow;
    }
  }

  // Delete session
  Future<void> delete(String id) async {
    try {
      await _storageService.deleteFocusSession(id);
    } catch (e) {
      rethrow;
    }
  }
}