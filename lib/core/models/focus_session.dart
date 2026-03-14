import 'package:uuid/uuid.dart';

// Domain entity for a focus session
class FocusSession {
  final String id;
  final int durationMinutes; // Selected session length
  final int elapsedSeconds; // How long user actually focused
  final DateTime startedAt;
  final DateTime? endedAt;
  final bool completed; // True if session finished, false if abandoned
  final int distractionsCount; // How many times user left the app
  final String? notes; // Optional reflection notes

  FocusSession({
    String? id,
    required this.durationMinutes,
    int? elapsedSeconds,
    DateTime? startedAt,
    this.endedAt,
    required this.completed,
    int? distractionsCount,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        elapsedSeconds = elapsedSeconds ?? 0,
        startedAt = startedAt ?? DateTime.now(),
        distractionsCount = distractionsCount ?? 0;

  // Calculate how much time remains (for UI display)
  int get remainingSeconds => (durationMinutes * 60) - elapsedSeconds;

  // Was session abandoned early or not 
  bool get wasAbandoned => !completed && elapsedSeconds > 0;

  // Percentage of session completed
  double get completionPercentage =>
      (elapsedSeconds / (durationMinutes * 60)).clamp(0.0, 1.0);

  // Copy with new values
  FocusSession copyWith({
    String? id,
    int? durationMinutes,
    int? elapsedSeconds,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? completed,
    int? distractionsCount,
    String? notes,
  }) {
    return FocusSession(
      id: id ?? this.id,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      completed: completed ?? this.completed,
      distractionsCount: distractionsCount ?? this.distractionsCount,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'FocusSession(id: $id, duration: ${durationMinutes}m, elapsed: ${elapsedSeconds}s, completed: $completed)';
}