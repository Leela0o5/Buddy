import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/timer_service.dart';
import '../../../../core/models/focus_session.dart';
import '../state/timer_provider.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/reward_animation_widget.dart';

// Active focus session timer screen
class TimerScreen extends ConsumerStatefulWidget {
  final int durationMinutes;

  const TimerScreen({
    Key? key,
    required this.durationMinutes,
  }) : super(key: key);

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  bool _isPaused = false;
  bool _sessionComplete = false;
  int _lastMinute = 0;

  void _defer(void Function() action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerService = ref.watch(timerServiceProvider);
    final currentSession = ref.watch(currentSessionProvider);
    final elapsedSecondsFromStream =
        ref.watch(timerStreamProvider).asData?.value;

    if (currentSession == null) {
      return const Scaffold(
        body: Center(child: Text('Starting session...')),
      );
    }

    if (elapsedSecondsFromStream != null &&
        elapsedSecondsFromStream != currentSession.elapsedSeconds) {
      _defer(() {
        ref
            .read(currentSessionProvider.notifier)
            .updateElapsedTime(elapsedSecondsFromStream);
      });
    }

    final remainingSeconds = currentSession.remainingSeconds;

    // Trigger haptic every minute
    if (remainingSeconds > 0 && _lastMinute != remainingSeconds ~/ 60) {
      _lastMinute = remainingSeconds ~/ 60;
      HapticService.lightVibration();
    }

    // Check if session is complete
    if (remainingSeconds <= 0 && !_sessionComplete) {
      _defer(() {
        setState(() {
          _sessionComplete = true;
        });
        HapticService.successVibration();
        timerService.stop();
        ref.read(currentSessionProvider.notifier).completeSession();

        // Save session to storage
        final session = ref.read(currentSessionProvider);
        if (session != null) {
          ref.read(focusSessionRepositoryProvider).save(session);
        }
      });
    }

    return BaseScaffold(
      title: AppStrings.focusSession,
      body: _sessionComplete
          ? _buildRewardScreen(context)
          : _buildTimerScreen(context, timerService, currentSession,
              remainingSeconds),
    );
  }

  /// Reward screen after completion
  Widget _buildRewardScreen(BuildContext context) {
    return RewardAnimationWidget(
      onComplete: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Moving to reflection...')),
        );
      },
    );
  }

  // Active timer screen
  Widget _buildTimerScreen(
    BuildContext context,
    TimerService timerService,
    FocusSession currentSession,
    int remainingSeconds,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Circular timer animation
        CircularTimerWidget(
          remainingSeconds: remainingSeconds,
          totalSeconds: currentSession.durationMinutes * 60,
          isRunning: timerService.isRunning,
        ),
        const SizedBox(height: 40),

        // Time visualization
        _buildTimeVisualization(context, currentSession),
        const SizedBox(height: 40),

        // Control buttons
        _buildControlButtons(context, timerService),
        const SizedBox(height: 40),

        // Session info
        _buildSessionInfo(context, currentSession),
      ],
    );
  }

  // Progress visualization - Time passing indicator
  Widget _buildTimeVisualization(
    BuildContext context,
    FocusSession currentSession,
  ) {
    final totalSeconds = currentSession.durationMinutes * 60;
    final elapsedSeconds = totalSeconds - currentSession.remainingSeconds;
    final progress = elapsedSeconds / totalSeconds;
    final elapsedMinutes = elapsedSeconds ~/ 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.youHaveBeenFocusing} $elapsedMinutes ${elapsedMinutes == 1 ? 'minute' : 'minutes'}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  // Control buttons (pause/resume/cancel)
  Widget _buildControlButtons(BuildContext context, TimerService timerService) {
    return Row(
      children: [
        // Pause/Resume button
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              HapticService.lightVibration();
              setState(() {
                _isPaused = !_isPaused;
              });
              if (_isPaused) {
                timerService.pause();
              } else {
                timerService.resume();
              }
            },
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(
              _isPaused
                  ? AppStrings.resumeSession
                  : AppStrings.pauseSession,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Cancel button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticService.warningVibration();
              _showCancelDialog(context, timerService);
            },
            icon: const Icon(Icons.close),
            label: const Text(AppStrings.cancelSession),
          ),
        ),
      ],
    );
  }

  // Session info card
  Widget _buildSessionInfo(BuildContext context, FocusSession currentSession) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  'Duration',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentSession.durationMinutes}m',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Distractions',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentSession.distractionsCount}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Cancel session confirmation dialog
  void _showCancelDialog(BuildContext context, TimerService timerService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Session?'),
        content: const Text('Are you sure you want to cancel this focus session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Continue'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentSessionProvider.notifier).abandonSession();
              timerService.stop();
              Navigator.pop(context);
              Navigator.pop(context); // Exit timer screen
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}