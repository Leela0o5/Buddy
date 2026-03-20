// Model for tracking focus streaks
class StreakData {
  final int currentStreak; // How many consecutive days
  final int bestStreak; // All-time best streak
  final DateTime lastSessionDate; // Last day with a completed session

  StreakData({
    required this.currentStreak,
    required this.bestStreak,
    required this.lastSessionDate,
  });

  // Copy with new values
  StreakData copyWith({
    int? currentStreak,
    int? bestStreak,
    DateTime? lastSessionDate,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }

  @override
  String toString() =>
      'StreakData(current: $currentStreak, best: $bestStreak, last: $lastSessionDate)';
}