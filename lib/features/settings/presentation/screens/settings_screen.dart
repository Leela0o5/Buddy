import 'package:flutter/material.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';

// Settings and preferences screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = false;
  bool _vibrationEnabled = true;
  bool _soundEnabled = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: AppStrings.settings,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display settings
            _buildSectionHeader(context, 'Display'),
            _buildSwitchTile(
              context,
              title: AppStrings.darkMode,
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
                // TODO: Day 13 - Wire to Riverpod theme provider
              },
            ),
            const Divider(),

            // Sound & Haptics
            _buildSectionHeader(context, 'Sound & Haptics'),
            _buildSwitchTile(
              context,
              title: AppStrings.hapticFeedback,
              value: _vibrationEnabled,
              onChanged: (value) => setState(() => _vibrationEnabled = value),
            ),
            _buildSwitchTile(
              context,
              title: AppStrings.soundFeedback,
              value: _soundEnabled,
              onChanged: (value) => setState(() => _soundEnabled = value),
            ),
            const Divider(),

            // Notifications
            _buildSectionHeader(context, 'Notifications'),
            _buildSwitchTile(
              context,
              title: AppStrings.enableNotifications,
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
            const Divider(),

            // About
            _buildSectionHeader(context, 'About'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: ListTile(
                title: Text('App Version'),
                trailing: Text(AppConstants.appVersion),
              ),
            ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: ListTile(
                title: Text('App Name'),
                trailing: Text(AppConstants.appName),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section header
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  // Toggle switch tile
  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}