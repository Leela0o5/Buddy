import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/timer_service.dart';
import '../../../../core/models/focus_session.dart';
import '../state/timer_provider.dart';
import '../state/distraction_provider.dart';
import '../../../settings/presentation/state/preferences_provider.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/reward_animation_widget.dart';
import '../../../../core/services/notification_service.dart';
import '../widgets/time_blindness_widget.dart';
import 'break_screen.dart';

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
  int _lastRecordedDistractionCount = 0;

   @override
  void initState() {
    super.initState();
    // Initialize notifications
    Future.microtask(() async {
      await NotificationService().initialize();
    });
  }

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
    final distractionCountFromStream =
        ref.watch(distractionStreamProvider).asData?.value;
    final hapticsEnabled = ref.watch(vibrationEnabledProvider);
    final soundsEnabled = ref.watch(soundEnabledProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    if (currentSession == null) {
      return const Scaffold(
        body: Center(child: Text('Starting session...')),
      );
    }

    // Update distraction count when a new distraction is detected
    if (distractionCountFromStream != null &&
        distractionCountFromStream != _lastRecordedDistractionCount) {
      _lastRecordedDistractionCount = distractionCountFromStream;
      _defer(() {
        ref
            .read(currentSessionProvider.notifier)
            .recordDistraction();
        if (notificationsEnabled) {
          NotificationService().showDistractionAlert();
        }
        debugPrint(
            ' Distraction recorded in session! Total: ${currentSession.distractionsCount + 1}');
      });
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
      if (hapticsEnabled) {
        HapticService.lightVibration();
      }
      if (soundsEnabled) {
        SoundService.click();
      }
    }

    // Check if session is complete
    if (remainingSeconds <= 0 && !_sessionComplete) {
      _defer(() {
        setState(() {
          _sessionComplete = true;
        });
        if (hapticsEnabled) {
          HapticService.successVibration();
        }
        if (soundsEnabled) {
          SoundService.alert();
        }
        if (notificationsEnabled) {
          NotificationService().showEncouragement('Great work completing your focus session.');
        }
        timerService.stop();
        ref.read(currentSessionProvider.notifier).completeSession();

        // Save session to storage
        final session = ref.read(currentSessionProvider);
        if (session != null) {
          ref.read(focusSessionRepositoryProvider).save(session);
          // Invalidate today's sessions provider so cycle display updates
          ref.invalidate(todaySessionsProvider);
        }
      });
    }

    return BaseScaffold(
      title: AppStrings.focusSession,
      body: _sessionComplete
          ? _buildRewardScreen(context)
          : _buildTimerScreen(
              context,
              timerService,
              currentSession,
              remainingSeconds,
              hapticsEnabled,
              soundsEnabled,
            ),
    );
  }

  /// Reward screen after completion
  Widget _buildRewardScreen(BuildContext context) {
    return RewardAnimationWidget(
      onComplete: () {
        // Show continue/break options
        _showPostSessionOptions(context);
      },
    );
  }

  void _showPostSessionOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Session Complete! 🎉'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              // Reset session and go home
              ref.read(currentSessionProvider.notifier).resetSession();
              ref.read(timerServiceProvider).stop();
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Go Home'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Get break duration based on session count
              final breakDuration = await ref.read(breakDurationProvider.future);
              
              if (context.mounted) {
                // Show break screen on top of timer 
                // So Skip button can return to timer screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BreakScreen(
                      breakDurationMinutes: breakDuration,
                      onBreakComplete: () {
                        // After break, ask if they want to continue
                        _showContinueSessionDialog(context);
                      },
                      onSkip: () {
                        // Auto-continue session after skipping break
                        Navigator.pop(context); // Close break screen
                        _continueSession(context);
                      },
                    ),
                  ),
                );
              }
            },
            child: const Text('Take Break'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Continue without break
              _continueSession(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showContinueSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ready to continue?'),
        content: const Text('Start another focus session?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Go to home
            },
            child: const Text('Rest more'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _continueSession(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _continueSession(BuildContext context) {
    // Exit all dialogs and get back to home
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    Future.microtask(() {
      ref.read(currentSessionProvider.notifier).resetSession();
      ref.read(timerServiceProvider).stop();
      
      // Start new session with selected duration
      final duration = ref.read(selectedDurationProvider);
      ref.read(currentSessionProvider.notifier).startSession(duration);
      ref.read(timerServiceProvider).start(duration * 60);
      
      // Push new timer screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TimerScreen(durationMinutes: duration),
        ),
      );
    });
  }

  // Active timer screen
  Widget _buildTimerScreen(
    BuildContext context,
    TimerService timerService,
    FocusSession currentSession,
    int remainingSeconds,
    bool hapticsEnabled,
    bool soundsEnabled,
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
        _buildControlButtons(
          context,
          timerService,
          hapticsEnabled,
          soundsEnabled,
        ),
        const SizedBox(height: 40),

        // Session info
        _buildSessionInfo(context, currentSession),
      ],
    );
  }

    /// Time visualization with encouragement
  Widget _buildTimeVisualization(
    BuildContext context,
    FocusSession currentSession,
  ) {
    final totalSeconds = currentSession.durationMinutes * 60;
    final elapsedSeconds = totalSeconds - currentSession.remainingSeconds;
    final elapsedMinutes = elapsedSeconds ~/ 60;

    return TimeBlindnessWidget(
      elapsedMinutes: elapsedMinutes,
      totalMinutes: currentSession.durationMinutes,
    );
  }

  // Control buttons (pause/resume/cancel)
  Widget _buildControlButtons(
    BuildContext context,
    TimerService timerService,
    bool hapticsEnabled,
    bool soundsEnabled,
  ) {
    final currentSession = ref.watch(currentSessionProvider);
    final canAdjust = !timerService.isRunning && 
        currentSession != null && 
        currentSession.elapsedSeconds == 0;

    return Column(
      children: [
        // Duration adjustment buttons (only when at start)
        if (canAdjust)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final duration = currentSession.durationMinutes;
                    if (duration > 5) {
                      final newDuration = duration - 5;
                      ref.read(currentSessionProvider.notifier).adjustDuration(newDuration);
                      ref.read(selectedDurationProvider.notifier).state = newDuration;
                      if (hapticsEnabled) HapticService.lightVibration();
                    }
                  },
                  icon: const Icon(Icons.remove_circle),
                  tooltip: 'Decrease time',
                ),
                const SizedBox(width: 16),
                Text(
                  '${currentSession.durationMinutes} min',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    final duration = currentSession.durationMinutes;
                    if (duration < 25) {
                      final newDuration = duration + 5;
                      ref.read(currentSessionProvider.notifier).adjustDuration(newDuration);
                      ref.read(selectedDurationProvider.notifier).state = newDuration;
                      if (hapticsEnabled) HapticService.lightVibration();
                    }
                  },
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Increase time',
                ),
              ],
            ),
          ),
        // Pause/Resume and Cancel buttons
        Row(
          children: [
            // Pause/Resume button
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (hapticsEnabled) {
                    HapticService.lightVibration();
                  }
                  if (soundsEnabled) {
                    SoundService.click();
                  }
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
                  if (hapticsEnabled) {
                    HapticService.warningVibration();
                  }
                  if (soundsEnabled) {
                    SoundService.alert();
                  }
                  _showCancelDialog(context, timerService);
                },
                icon: const Icon(Icons.close),
                label: const Text(AppStrings.cancelSession),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Session info card
  Widget _buildSessionInfo(BuildContext context, FocusSession currentSession) {
    final todaySessionsAsync = ref.watch(todaySessionsProvider);
    
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
            Column(
              children: [
                Text(
                  'Cycle',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                todaySessionsAsync.when(
                  data: (sessions) {
                    final positionInCycle = (sessions.length % 4) + 1;
                    return Text(
                      '$positionInCycle/4',
                      style: Theme.of(context).textTheme.titleLarge,
                    );
                  },
                  loading: () => const Text('-'),
                  error: (_, __) => const Text('?'),
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
              ref.read(currentSessionProvider.notifier).resetSession();
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