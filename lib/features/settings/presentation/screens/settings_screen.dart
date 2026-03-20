import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';
import '../state/preferences_provider.dart';

// Settings and preferences screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(currentPreferencesProvider);

    return BaseScaffold(
      title: AppStrings.settings,
      isScrollable: false,
      body: preferencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load settings')),
        data: (preferences) => ListView(
        children: [
          // Display settings
          _buildSectionHeader(context, 'Display'),
          _buildSwitchTile(
            context,
            title: AppStrings.darkMode,
            value: preferences.darkModeEnabled,
            onChanged: (value) async {
              await ref.read(setDarkModeProvider)(value);
            },
            ),
          const Divider(),

          // Sound & Haptics
          _buildSectionHeader(context, 'Sound & Haptics'),
          _buildSwitchTile(
            context,
            title: AppStrings.hapticFeedback,
            value: preferences.vibrationEnabled,
            onChanged: (value) async {
              await ref.read(setVibrationProvider)(value);
            },
            ),
          _buildSwitchTile(
            context,
            title: AppStrings.soundFeedback,
            value: preferences.soundEnabled,
            onChanged: (value) async {
              await ref.read(setSoundProvider)(value);
            },
            ),
          const Divider(),

          // Notifications
          _buildSectionHeader(context, 'Notifications'),
          _buildSwitchTile(
            context,
            title: 'Enable Notifications',
            value: preferences.notificationsEnabled,
            onChanged: (value) async {
              await ref.read(setNotificationsProvider)(value);
            },
            ),
          _buildNotificationTimeTile(
            context,
            ref,
            preferences.notificationHour,
            preferences.notificationMinute,
            preferences.notificationsEnabled,
          ),
          const Divider(),

          // App Info
          _buildSectionHeader(context, 'About'),
          _buildAppInfoTile(context),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildNotificationTimeTile(
    BuildContext context,
    WidgetRef ref,
    int currentHour,
    int currentMinute,
    bool notificationsEnabled,
  ) {
    final formattedTime =
        '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';

    return ListTile(
      title: const Text('Reminder Time'),
      subtitle: Text(
        notificationsEnabled ? formattedTime : 'Enable notifications to set a reminder time',
      ),
      trailing: const Icon(Icons.chevron_right),
      enabled: notificationsEnabled,
      onTap: notificationsEnabled
          ? () async {
              await _showTimePicker(context, ref, currentHour, currentMinute);
            }
          : null,
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    int currentHour,
    int currentMinute,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
    );

    if (picked == null) {
      return;
    }

    await ref.read(setNotificationTimeProvider)(picked.hour, picked.minute);
  }

  Widget _buildAppInfoTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buddy',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'ADHD-focused productivity app for building focus habits',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}