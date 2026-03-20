import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/constants.dart';
import '../state/timer_provider.dart';
import '../state/start_small_provider.dart';

// Prominent Start Small Mode button
class StartSmallButtonWidget extends ConsumerWidget {
  final VoidCallback? onStarted;

  const StartSmallButtonWidget({
    Key? key,
    this.onStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startSmallActive = ref.watch(startSmallModeProvider);

    return AnimatedScale(
      scale: startSmallActive ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            // Start 5-minute quick session
            ref.read(currentSessionProvider.notifier).startSession(5);
            ref.read(timerServiceProvider).start(5 * 60);
            ref.read(activateStartSmallProvider)(null);
            onStarted?.call();
          },
          icon: const Icon(Icons.flash_on, size: 20),
          label: const Text(
            AppStrings.startSmallMode,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
