import 'package:flutter/material.dart';
import 'dart:math' as math;

// Animated circular timer display with progress indicator
class CircularTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;

  const CircularTimerWidget({
    Key? key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
  }) : super(key: key);

  // Calculate progress (0 - 1), clamped to ensure it reaches 100%
  double get progress {
    final calculatedProgress = (totalSeconds - remainingSeconds) / totalSeconds;
    return calculatedProgress.clamp(0.0, 1.0);
  }

  // Calculate color based on time remaining 
  Color _getProgressColor(BuildContext context) {
    if (progress < 0.5) {
      // First half -- green to yellow
      final lerp = progress * 2; 
      return Color.lerp(
        Colors.green,
        Colors.yellow,
        lerp,
      )!;
    } else {
      // Second half -- yellow to red
      final lerp = (progress - 0.5) * 2; // 0 to 1
      return Color.lerp(
        Colors.yellow,
        Colors.red,
        lerp,
      )!;
    }
  }

  // Format time string (MM:SS)
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Custom paint for circular progress
        CustomPaint(
          size: const Size(240, 240),
          painter: _CircularProgressPainter(
            progress: progress,
            progressColor: _getProgressColor(context),
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            strokeWidth: 4,
          ),
        ),
        // Time display
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(remainingSeconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isRunning ? 'Focusing...' : 'Paused',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter for circular progress indicator
class _CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Draw progress arc
    if (progress > 0) {
      final sweepAngle = (progress * 2 * math.pi);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // Draw outer circle border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = progressColor.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}