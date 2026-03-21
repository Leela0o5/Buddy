import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/services/sound_service.dart';
import '../../../../core/services/timer_service.dart';
import '../state/timer_provider.dart';
import '../../../settings/presentation/state/preferences_provider.dart';
import '../widgets/circular_timer_widget.dart';

class BreakScreen extends ConsumerStatefulWidget {
  final int breakDurationMinutes;
  final VoidCallback onBreakComplete;
  final VoidCallback? onSkip;

  const BreakScreen({
    Key? key,
    this.breakDurationMinutes = 5,
    required this.onBreakComplete,
    this.onSkip,
  }) : super(key: key);

  @override
  ConsumerState<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends ConsumerState<BreakScreen> {
  late TimerService _breakTimerService;
  bool _isPaused = false;
  int _lastMinute = 0;
  bool _breakComplete = false;

  @override
  void initState() {
    super.initState();
    _breakTimerService = TimerService();
    // Delay provider modification to avoid building during widget lifecycle
    Future.microtask(() {
      _breakTimerService.start(widget.breakDurationMinutes * 60);
      ref.read(breakStateProvider.notifier).startBreak(widget.breakDurationMinutes);
    });
  }

  @override
  void dispose() {
    _breakTimerService.stop();
    super.dispose();
  }

  void _defer(void Function() action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hapticsEnabled = ref.watch(vibrationEnabledProvider);
    final soundsEnabled = ref.watch(soundEnabledProvider);

    return BaseScaffold(
      title: 'Break Time',
      body: StreamBuilder<int>(
        stream: _breakTimerService.elapsedStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final elapsedSeconds = snapshot.data ?? 0;
          final totalSeconds = widget.breakDurationMinutes * 60;
          final remainingSeconds = totalSeconds - elapsedSeconds;

          // Trigger haptic every minute
          if (remainingSeconds > 0 && _lastMinute != remainingSeconds ~/ 60) {
            _lastMinute = remainingSeconds ~/ 60;
            _defer(() {
              if (hapticsEnabled) {
                HapticService.lightVibration();
              }
              if (soundsEnabled) {
                SoundService.click();
              }
            });
          }

          // Break complete
          if (remainingSeconds <= 0 && !_breakComplete) {
            _breakComplete = true;
            _defer(() {
              if (hapticsEnabled) {
                HapticService.successVibration();
              }
              if (soundsEnabled) {
                SoundService.alert();
              }
              _breakTimerService.stop();
              ref.read(breakStateProvider.notifier).endBreak();
              widget.onBreakComplete();
              Navigator.pop(context);
            });
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),

              // Circular timer animation
              CircularTimerWidget(
                remainingSeconds: remainingSeconds,
                totalSeconds: totalSeconds,
                isRunning: _breakTimerService.isRunning,
              ),
              const SizedBox(height: 30),

              // Break type indicator with cycle info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.breakDurationMinutes >= 15
                      ? Colors.green.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.breakDurationMinutes >= 15
                          ? ' Long Break - Recharge fully!'
                          : ' Short Break - Refresh quickly',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: widget.breakDurationMinutes >= 15
                                ? Colors.green
                                : Colors.blue,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCycleProgressText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.breakDurationMinutes >= 15
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Break message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Take a moment to rest and relax',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 20),

              // Break tips
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What to do during this break:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<String>>(
                        future: Future.value(_getBreakTips()),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }
                          final tips = snapshot.data ?? [];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: tips
                                .map((tip) {
                                  final parts = tip.split(' ');
                                  final emoji = parts.isNotEmpty ? parts[0] : '•';
                                  final text = parts.length > 1 
                                      ? parts.sublist(1).join(' ') 
                                      : '';
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          emoji,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            text,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Control buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Pause/Resume button
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          if (hapticsEnabled) {
                            HapticService.lightVibration();
                          }
                          setState(() {
                            _isPaused = !_isPaused;
                          });
                          if (_isPaused) {
                            _breakTimerService.pause();
                            ref.read(breakStateProvider.notifier).pauseBreak();
                          } else {
                            _breakTimerService.resume();
                            ref.read(breakStateProvider.notifier).resumeBreak();
                          }
                        },
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                        label: Text(
                          _isPaused ? 'Resume' : 'Pause',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Skip button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (hapticsEnabled) {
                            HapticService.lightVibration();
                          }
                          _breakTimerService.stop();
                          ref.read(breakStateProvider.notifier).endBreak();
                          // If onSkip callback provided, call it (auto-continue session)
                          // Otherwise just pop back to timer
                          if (widget.onSkip != null) {
                            widget.onSkip!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.fast_forward),
                        label: const Text('Skip'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  List<String> _getBreakTips() {
    if (widget.breakDurationMinutes >= 15) {
      return [
        '🚶 Take a walk around your space',
        '👀 Rest your eyes - look away from screens',
        '💧 Drink water and stay hydrated',
        '🧘 Do some light stretching or yoga',
        '🎵 Listen to your favorite music',
        '🌬️ Take deep breaths and meditate',
      ];
    } else {
      return [
        '💧 Grab a glass of water',
        '👀 Look away from the screen',
        '🧘 Take 3-5 deep breaths',
        '🚶 Stand up and stretch quickly',
        '🌬️ Clear your mind and relax',
        '⚡ Get ready for your next session',
      ];
    }
  }

  String _getCycleProgressText() {
    // Calculate cycle position based on completed sessions
    // Sessions are 0-indexed in the list, so completed count = length
    final todaySessionsAsync = ref.watch(todaySessionsProvider);
    
    return todaySessionsAsync.when(
      data: (sessions) {
        final completedCount = sessions.length;
        final positionInCycle = (completedCount % 4) + 1;
        final nextLongBreakIn = 4 - (completedCount % 4);
        
        if (widget.breakDurationMinutes >= 15) {
          return '🎉 Completed a full cycle! Start a new one with $nextLongBreakIn more sessions.';
        } else {
          return '👉 Session $positionInCycle of 4 in cycle • $nextLongBreakIn more until long break';
        }
      },
      loading: () => 'Loading cycle info...',
      error: (_, __) => 'Cycle progress',
    );
  }
}
