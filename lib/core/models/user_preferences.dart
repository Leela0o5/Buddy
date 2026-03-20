/// User settings and preferences
class UserPreferences {
  final bool darkModeEnabled;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final int notificationHour; // Which hour to send daily reminder (0-23)
  final int notificationMinute; // Which minute to send daily reminder (0-59)
  final DateTime lastUpdated;

  UserPreferences({
    bool? darkModeEnabled,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
    DateTime? lastUpdated,
  })  : darkModeEnabled = darkModeEnabled ?? false,
        vibrationEnabled = vibrationEnabled ?? true,
        soundEnabled = soundEnabled ?? false,
        notificationsEnabled = notificationsEnabled ?? true,
        notificationHour = notificationHour ?? 9,
      notificationMinute = notificationMinute ?? 0,
        lastUpdated = lastUpdated ?? DateTime.now();

  UserPreferences copyWith({
    bool? darkModeEnabled,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? notificationsEnabled,
    int? notificationHour,
    int? notificationMinute,
    DateTime? lastUpdated,
  }) {
    return UserPreferences(
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  @override
  String toString() =>
      'UserPreferences(darkMode: $darkModeEnabled, vibration: $vibrationEnabled, notifications: $notificationsEnabled)';
}