import 'package:flutter/material.dart';
import 'dart:math' as math;

// Reward animation shown when session completes
class RewardAnimationWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const RewardAnimationWidget({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<RewardAnimationWidget> createState() => _RewardAnimationWidgetState();
}

class _RewardAnimationWidgetState extends State<RewardAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });

    _generateParticles();
    _controller.forward();
  }

  // Generate random confetti particles
  void _generateParticles() {
    _particles = List.generate(50, (_) {
      return _ConfettiParticle(
        x: math.Random().nextDouble() * 300 - 150,
        y: math.Random().nextDouble() * 100,
        vx: (math.Random().nextDouble() - 0.5) * 4,
        vy: (math.Random().nextDouble() - 0.5) * 8,
        color: _getRandomColor(),
        life: math.Random().nextDouble() * 0.8 + 0.2,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFF4A90E2), // blue
      const Color(0xFF2ECC71), // green
      const Color(0xFFE88D4C), // orange
      const Color(0xFFFDB913), // yellow
      const Color(0xFF27AE60), // dark green
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Confetti particles
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ConfettiPainter(
                progress: _controller.value,
                particles: _particles,
              ),
            ),
            // Center celebration message
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.celebration,
                      size: 80,
                      color: Color(0xFFFDB913),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Great Focus!',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Session Complete! 🎉',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Model for individual confetti particle
class _ConfettiParticle {
  double x;
  double y;
  final double vx;
  final double vy;
  final Color color;
  final double life;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.life,
  });

  void update() {
    x += vx;
    y += vy;
  }
}

// Custom painter for confetti animation
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final alpha = ((1 - progress) * 255).toInt();
      if (alpha <= 0) continue;

      particle.update();

      final paint = Paint()
        ..color = particle.color.withAlpha(alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          size.width / 2 + particle.x,
          size.height / 4 + particle.y + (progress * 100),
        ),
        4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}