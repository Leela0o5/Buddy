import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';
import '../state/timer_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentSession = ref.watch(currentSessionProvider);
    ref.watch(timerStreamProvider);

    if (currentSession == null) {
      return const Scaffold(
        body: Center(child: Text('Starting session...')),
      );
    }

    final remainingSeconds = currentSession.remainingSeconds;
    final elapsedSeconds = currentSession.elapsedSeconds;

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return BaseScaffold(
      title: AppStrings.focusSession,
      body: Column(
        children: [
          const SizedBox(height: 40),

          // Large countdown timer
          _buildTimerDisplay(context, timeString),
          const SizedBox(height: 40),

          // Time visualization
          _buildTimeVisualization(context, elapsedSeconds),
          const SizedBox(height: 40),

          // Control buttons
          _buildControlButtons(context),
          const SizedBox(height: 40),

          // Session info
          _buildSessionInfo(context),
        ],
      ),
    );
  }

  // Large countdown display
  Widget _buildTimerDisplay(BuildContext context, String timeString) {
    return Center(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
        child: Center(
          child: Text(
            timeString,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ),
    );
  }

  //  Time passing indicator
  Widget _buildTimeVisualization(BuildContext context, int elapsedSeconds) {
    final totalSeconds = widget.durationMinutes * 60;
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
  Widget _buildControlButtons(BuildContext context) {
    final timerService = ref.watch(timerServiceProvider);

    return Row(
      children: [
        // Pause/Resume button
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
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
              _showCancelDialog(context);
            },
            icon: const Icon(Icons.close),
            label: const Text(AppStrings.cancelSession),
          ),
        ),
      ],
    );
  }

  // Session info card
  Widget _buildSessionInfo(BuildContext context) {
    final currentSession = ref.watch(currentSessionProvider);

    if (currentSession == null) {
      return const SizedBox.shrink();
    }

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
  void _showCancelDialog(BuildContext context) {
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
              ref.read(timerServiceProvider).stop();
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