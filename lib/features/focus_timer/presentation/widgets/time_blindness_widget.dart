import 'package:flutter/material.dart';

// Widget that combats time blindness with visual and text cues
class TimeBlindnessWidget extends StatelessWidget {
  final int elapsedMinutes;
  final int totalMinutes;

  const TimeBlindnessWidget({
    Key? key,
    required this.elapsedMinutes,
    required this.totalMinutes,
  }) : super(key: key);

  // Get encouragement message based on elapsed time
  String _getEncouragementMessage() {
    if (elapsedMinutes == 0) {
      return 'You just started! You\'ve got this! 💪';
    } else if (elapsedMinutes == 5) {
      return '5 minutes down! Great start! 🚀';
    } else if (elapsedMinutes == totalMinutes ~/ 2) {
      return 'Halfway there! Keep up the momentum! 🔥';
    } else if (elapsedMinutes == totalMinutes - 5) {
      return 'Almost done! Final stretch! 🎯';
    } else if (elapsedMinutes % 5 == 0 && elapsedMinutes > 0) {
      return '$elapsedMinutes minutes of pure focus! Amazing! ✨';
    }
    return '';
  }

  // Get color based on progress
  Color _getProgressColor(BuildContext context) {
    final progress = elapsedMinutes / totalMinutes;
    if (progress < 0.5) {
      return Colors.green;
    } else if (progress < 0.75) {
      return Colors.yellow.shade700;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final encouragement = _getEncouragementMessage();
    final progressColor = _getProgressColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main time display
        Text(
          'You\'ve been focusing for $elapsedMinutes ${elapsedMinutes == 1 ? 'minute' : 'minutes'}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
        ),
        const SizedBox(height: 12),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (elapsedMinutes / totalMinutes).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ),
        const SizedBox(height: 12),

        // Encouragement message (if any)
        if (encouragement.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: progressColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: progressColor.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: progressColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    encouragement,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}