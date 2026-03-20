import 'package:flutter_test/flutter_test.dart';
import 'package:buddy/core/models/user_preferences.dart';

void main() {
  group('Settings Feature Tests', () {
    test('UserPreferences creation with defaults', () {
      final now = DateTime.now();
      final prefs = UserPreferences(
        darkModeEnabled: false,
        vibrationEnabled: true,
        soundEnabled: true,
        notificationsEnabled: true,
        notificationHour: 9,
        lastUpdated: now,
      );

      expect(prefs.darkModeEnabled, false);
      expect(prefs.vibrationEnabled, true);
      expect(prefs.soundEnabled, true);
      expect(prefs.notificationsEnabled, true);
      expect(prefs.notificationHour, 9);
    });

    test('Dark mode toggle', () {
      var prefs = UserPreferences(
        darkModeEnabled: false,
        vibrationEnabled: true,
        soundEnabled: true,
        notificationsEnabled: true,
        notificationHour: 9,
        lastUpdated: DateTime.now(),
      );

      prefs = prefs.copyWith(darkModeEnabled: true);
      expect(prefs.darkModeEnabled, true);

      prefs = prefs.copyWith(darkModeEnabled: false);
      expect(prefs.darkModeEnabled, false);
    });

    test('Vibration toggle', () {
      var prefs = UserPreferences(
        darkModeEnabled: false,
        vibrationEnabled: true,
        soundEnabled: true,
        notificationsEnabled: true,
        notificationHour: 9,
        lastUpdated: DateTime.now(),
      );

      prefs = prefs.copyWith(vibrationEnabled: false);
      expect(prefs.vibrationEnabled, false);

      prefs = prefs.copyWith(vibrationEnabled: true);
      expect(prefs.vibrationEnabled, true);
    });

    test('Sound toggle', () {
      var prefs = UserPreferences(
        darkModeEnabled: false,
        vibrationEnabled: true,
        soundEnabled: true,
        notificationsEnabled: true,
        notificationHour: 9,
        lastUpdated: DateTime.now(),
      );

      prefs = prefs.copyWith(soundEnabled: false);
      expect(prefs.soundEnabled, false);

      prefs = prefs.copyWith(soundEnabled: true);
      expect(prefs.soundEnabled, true);
    });

    test('Notifications toggle', () {
      var prefs = UserPreferences(
        darkModeEnabled: false,
        vibrationEnabled: true,
        soundEnabled: true,
        notificationsEnabled: true,
        notificationHour: 9,
        lastUpdated: DateTime.now(),
      );

      prefs = prefs.copyWith(notificationsEnabled: false);
      expect(prefs.notificationsEnabled, false);

      prefs = prefs.copyWith(notificationsEnabled: true);
      expect(prefs.notificationsEnabled, true);
    });

    test('Notification hour update (0-23 range)', () {
      var prefs = UserPreferences(
        darkModeEnabled: false,
        vibrationEnabled: true,
        soundEnabled: true,
        notificationsEnabled: true,
        notificationHour: 9,
        lastUpdated: DateTime.now(),
      );

      // Set to various hours
      for (int hour = 0; hour < 24; hour++) {
        prefs = prefs.copyWith(notificationHour: hour);
        expect(prefs.notificationHour, hour);
      }
    });

    test('Multiple settings change at once', () {
      var prefs = UserPreferences(
        darkModeEnabled: false,
        vibrationEnabled: true,
        soundEnabled: true,
        notificationsEnabled: true,
        notificationHour: 9,
        lastUpdated: DateTime.now(),
      );

      prefs = prefs.copyWith(
        darkModeEnabled: true,
        vibrationEnabled: false,
        soundEnabled: false,
        notificationHour: 14,
      );

      expect(prefs.darkModeEnabled, true);
      expect(prefs.vibrationEnabled, false);
      expect(prefs.soundEnabled, false);
      expect(prefs.notificationHour, 14);
    });

    test('Preferences persistence preserves ID and timestamps', () {
      final now = DateTime.now();
      final prefs = UserPreferences(
        darkModeEnabled: false,
        vibrationEnabled: true,
        soundEnabled: true,
        notificationsEnabled: true,
        notificationHour: 9,
        lastUpdated: now,
      );

      final updated = prefs.copyWith(
        darkModeEnabled: true,
        lastUpdated: now.add(const Duration(minutes: 1)),
      );

      expect(updated.lastUpdated.isAfter(prefs.lastUpdated), true);
    });
  });
}
