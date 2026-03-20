import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/hive_storage_service.dart';
import '../../data/repositories/preferences_repository.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return HiveStorageService();
});

// Preferences repository provider
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository(
    storageService: ref.watch(storageServiceProvider),
  );
});

class PreferencesController extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    final repository = ref.watch(preferencesRepositoryProvider);
    final existing = await repository.getPreferences();
    if (existing != null) {
      return existing;
    }

    final defaults = UserPreferences();
    await repository.updatePreferences(defaults);
    return defaults;
  }

  Future<void> _persist(UserPreferences updated) async {
    state = AsyncData(updated);
    final repository = ref.read(preferencesRepositoryProvider);
    await repository.updatePreferences(updated);
  }

  Future<void> setDarkMode(bool enabled) async {
    final current = state.valueOrNull ?? await future;
    await _persist(current.copyWith(darkModeEnabled: enabled));
  }

  Future<void> setVibrationEnabled(bool enabled) async {
    final current = state.valueOrNull ?? await future;
    await _persist(current.copyWith(vibrationEnabled: enabled));
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final current = state.valueOrNull ?? await future;
    await _persist(current.copyWith(soundEnabled: enabled));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final current = state.valueOrNull ?? await future;
    await _persist(current.copyWith(notificationsEnabled: enabled));

    if (!enabled) {
      await NotificationService().cancelAll();
    } else {
      await NotificationService().initialize();
    }
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    final current = state.valueOrNull ?? await future;
    await _persist(
      current.copyWith(
        notificationHour: hour,
        notificationMinute: minute,
      ),
    );
  }
}

final currentPreferencesProvider =
    AsyncNotifierProvider<PreferencesController, UserPreferences>(
  PreferencesController.new,
);

final darkModeProvider = Provider<bool>((ref) {
  final prefs = ref.watch(currentPreferencesProvider).valueOrNull;
  return prefs?.darkModeEnabled ?? false;
});

final vibrationEnabledProvider = Provider<bool>((ref) {
  final prefs = ref.watch(currentPreferencesProvider).valueOrNull;
  return prefs?.vibrationEnabled ?? true;
});

final soundEnabledProvider = Provider<bool>((ref) {
  final prefs = ref.watch(currentPreferencesProvider).valueOrNull;
  return prefs?.soundEnabled ?? true;
});

final notificationsEnabledProvider = Provider<bool>((ref) {
  final prefs = ref.watch(currentPreferencesProvider).valueOrNull;
  return prefs?.notificationsEnabled ?? true;
});

final notificationHourProvider = Provider<int>((ref) {
  final prefs = ref.watch(currentPreferencesProvider).valueOrNull;
  return prefs?.notificationHour ?? 9;
});

final notificationMinuteProvider = Provider<int>((ref) {
  final prefs = ref.watch(currentPreferencesProvider).valueOrNull;
  return prefs?.notificationMinute ?? 0;
});

final setDarkModeProvider = Provider<Future<void> Function(bool)>((ref) {
  return (bool enabled) async {
    await ref.read(currentPreferencesProvider.notifier).setDarkMode(enabled);
  };
});

final setVibrationProvider = Provider<Future<void> Function(bool)>((ref) {
  return (bool enabled) async {
    await ref
        .read(currentPreferencesProvider.notifier)
        .setVibrationEnabled(enabled);
  };
});

final setSoundProvider = Provider<Future<void> Function(bool)>((ref) {
  return (bool enabled) async {
    await ref.read(currentPreferencesProvider.notifier).setSoundEnabled(enabled);
  };
});

final setNotificationsProvider = Provider<Future<void> Function(bool)>((ref) {
  return (bool enabled) async {
    await ref
        .read(currentPreferencesProvider.notifier)
        .setNotificationsEnabled(enabled);
  };
});

final setNotificationTimeProvider =
    Provider<Future<void> Function(int, int)>((ref) {
  return (int hour, int minute) async {
    await ref
        .read(currentPreferencesProvider.notifier)
        .setNotificationTime(hour, minute);
  };
});
