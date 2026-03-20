import '../../../../core/models/user_preferences.dart';
import '../../../../core/services/storage_service.dart';

// Repository for user preferences and settings
class PreferencesRepository {
  final StorageService storageService;

  PreferencesRepository({required this.storageService});

  // Get current preferences
  Future<UserPreferences?> getPreferences() async {
    return await storageService.getPreferences();
  }

  // Update preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    await storageService.savePreferences(preferences);
  }

  Future<UserPreferences> _getOrCreatePreferences() async {
    final existing = await getPreferences();
    if (existing != null) {
      return existing;
    }

    final defaults = UserPreferences();
    await updatePreferences(defaults);
    return defaults;
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    final prefs = await _getOrCreatePreferences();
    await setDarkMode(!prefs.darkModeEnabled);
  }

  Future<void> setDarkMode(bool enabled) async {
    final prefs = await _getOrCreatePreferences();
    await updatePreferences(prefs.copyWith(darkModeEnabled: enabled));
  }

  // Toggle vibration
  Future<void> toggleVibration() async {
    final prefs = await _getOrCreatePreferences();
    await setVibrationEnabled(!prefs.vibrationEnabled);
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final prefs = await _getOrCreatePreferences();
    await updatePreferences(prefs.copyWith(vibrationEnabled: enabled));
  }

  // Toggle sound
  Future<void> toggleSound() async {
    final prefs = await _getOrCreatePreferences();
    await setSoundEnabled(!prefs.soundEnabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await _getOrCreatePreferences();
    await updatePreferences(prefs.copyWith(soundEnabled: enabled));
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    final prefs = await _getOrCreatePreferences();
    await setNotificationsEnabled(!prefs.notificationsEnabled);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _getOrCreatePreferences();
    await updatePreferences(prefs.copyWith(notificationsEnabled: enabled));
  }

  // Set notification hour
  Future<void> setNotificationHour(int hour) async {
    final prefs = await _getOrCreatePreferences();
    await updatePreferences(prefs.copyWith(notificationHour: hour));
  }

  Future<void> setNotificationTime({
    required int hour,
    required int minute,
  }) async {
    final prefs = await _getOrCreatePreferences();
    await updatePreferences(
      prefs.copyWith(
        notificationHour: hour,
        notificationMinute: minute,
      ),
    );
  }
}
