import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';
import '../state/timer_provider.dart';
import '../widgets/start_small_button_widget.dart';
import 'timer_screen.dart';

// Home screen with focus timer selector and quick stats
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDuration = ref.watch(selectedDurationProvider);
    final todayCount = ref.watch(todayCompletedCountProvider);
    final streak = ref.watch(currentStreakProvider);

    return BaseScaffold(
      title: AppStrings.homeTab,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Large circular timer placeholder
            _buildTimerPlaceholder(context, selectedDuration),
            const SizedBox(height: 40),

            // Session duration selector
            _buildDurationSelector(context, ref, selectedDuration),
            const SizedBox(height: 40),

            // Start Focus button
            _buildStartButtons(context, ref, selectedDuration),
            const SizedBox(height: 40),

            // Quick stats
            _buildQuickStats(context, todayCount, streak),
          ],
        ),
      ),
    );
  }

  // Large circular timer display placeholder
  Widget _buildTimerPlaceholder(BuildContext context, int duration) {
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
                '$duration:00',
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
  Widget _buildDurationSelector(
    BuildContext context,
    WidgetRef ref,
    int selectedDuration,
  ) {
    final isSessionActive = ref.watch(isSessionActiveProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectDuration,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: isSessionActive ? 0.5 : 1.0,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.allSessionDurations.map((duration) {
              final isSelected = selectedDuration == duration;
              return ChoiceChip(
                label: Text('${duration}m'),
                selected: isSelected,
                onSelected: isSessionActive
                    ? null
                    : (selected) {
                        ref.read(selectedDurationProvider.notifier).state = duration;
                      },
              );
            }).toList(),
          ),
        ),
        if (isSessionActive)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Duration locked during active session',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
      ],
    );
  }

  // Start buttons (normal + start small mode)
  Widget _buildStartButtons(
    BuildContext context,
    WidgetRef ref,
    int selectedDuration,
  ) {
    final isSessionActive = ref.watch(isSessionActiveProvider);

    return Column(
      children: [
        if (isSessionActive)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Session in progress. Complete or cancel it first.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Main start button
        SizedBox(
          width: double.infinity,
          height: AppConstants.largeButtonHeight,
          child: FilledButton.icon(
            onPressed: isSessionActive
                ? null
                : () {
                    // Start session with selected duration
                    ref.read(currentSessionProvider.notifier).startSession(selectedDuration);
                    ref.read(timerServiceProvider).start(selectedDuration * 60);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TimerScreen(durationMinutes: selectedDuration),
                      ),
                    );
                  },
            icon: const Icon(Icons.play_arrow),
            label: const Text(AppStrings.startFocus),
          ),
        ),
        const SizedBox(height: 12),
        // Start Small Mode or View Active Timer
        SizedBox(
          width: double.infinity,
          height: AppConstants.largeButtonHeight,
          child: isSessionActive
              ? FilledButton.icon(
                  onPressed: () {
                    // Go back to active timer
                    final currentSession = ref.read(currentSessionProvider);
                    if (currentSession != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TimerScreen(
                            durationMinutes: currentSession.durationMinutes,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.timer),
                  label: const Text('View Active Timer'),
                )
              : StartSmallButtonWidget(
                  onStarted: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TimerScreen(durationMinutes: 5),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Quick stats display
  Widget _buildQuickStats(
    BuildContext context,
    AsyncValue<int> todayCount,
    AsyncValue<int> streak,
  ) {
    return Row(
      children: [
        Expanded(
          child: todayCount.when(
            data: (count) => _buildStatCard(
              context,
              title: AppStrings.todaySessions,
              value: count.toString(),
              icon: Icons.check_circle_outline,
            ),
            loading: () => _buildStatCard(
              context,
              title: AppStrings.todaySessions,
              value: '...',
              icon: Icons.check_circle_outline,
            ),
            error: (_, __) => _buildStatCard(
              context,
              title: AppStrings.todaySessions,
              value: '0',
              icon: Icons.check_circle_outline,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: streak.when(
            data: (streakValue) => _buildStatCard(
              context,
              title: AppStrings.currentStreak,
              value: streakValue.toString(),
              icon: Icons.local_fire_department_outlined,
            ),
            loading: () => _buildStatCard(
              context,
              title: AppStrings.currentStreak,
              value: '...',
              icon: Icons.local_fire_department_outlined,
            ),
            error: (_, __) => _buildStatCard(
              context,
              title: AppStrings.currentStreak,
              value: '0',
              icon: Icons.local_fire_department_outlined,
            ),
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