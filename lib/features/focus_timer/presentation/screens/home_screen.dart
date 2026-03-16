import 'package:flutter/material.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';

// Home screen with focus timer selector and quick stats
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDuration = AppConstants.normalFocus; // 15 min default

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: AppStrings.homeTab,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Large circular timer placeholder
            _buildTimerPlaceholder(context),
            const SizedBox(height: 40),

            // Session duration selector
            _buildDurationSelector(context),
            const SizedBox(height: 40),

            // Start Focus button
            _buildStartButtons(context),
            const SizedBox(height: 40),

            // Quick stats
            _buildQuickStats(context),
          ],
        ),
      ),
    );
  }

  // Large circular timer display placeholder
  Widget _buildTimerPlaceholder(BuildContext context) {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_selectedDuration:00',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to focus?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Session duration selector buttons
  Widget _buildDurationSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectDuration,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.allSessionDurations.map((duration) {
            final isSelected = _selectedDuration == duration;
            return ChoiceChip(
              label: Text('${duration}m'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedDuration = duration;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Start buttons (normal + start small mode)
  Widget _buildStartButtons(BuildContext context) {
    return Column(
      children: [
        // Main start button
        SizedBox(
          width: double.infinity,
          height: AppConstants.largeButtonHeight,
          child: FilledButton.icon(
            onPressed: () {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting $_selectedDuration min session...'),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text(AppStrings.startFocus),
          ),
        ),
        const SizedBox(height: 12),
        // Start Small Mode alternative
        SizedBox(
          width: double.infinity,
          height: AppConstants.largeButtonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Starting 5 min quick session...'),
                ),
              );
            },
            icon: const Icon(Icons.flash_on),
            label: const Text(AppStrings.startSmallMode),
          ),
        ),
      ],
    );
  }

  // Quick stats display
  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: AppStrings.todaySessions,
            value: '0',
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            title: AppStrings.currentStreak,
            value: '0',
            icon: Icons.local_fire_department_outlined,
          ),
        ),
      ],
    );
  }

  // Individual stat card
  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}