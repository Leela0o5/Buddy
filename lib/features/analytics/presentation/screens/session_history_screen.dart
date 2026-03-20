import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/focus_session.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../focus_timer/presentation/state/timer_provider.dart';
import '../../../reflection/presentation/state/reflection_provider.dart';

// Screen showing all past focus sessions with details
class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({Key? key}) : super(key: key);

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • HH:mm').format(date);
  }

  Icon _getStatusIcon(bool completed) {
    return Icon(
      completed ? Icons.check_circle : Icons.cancel,
      color: completed ? Colors.green : Colors.grey,
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSessions = ref.watch(allSessionsProvider);

    return BaseScaffold(
      title: 'Session History',
      isScrollable: false,
      body: allSessions.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a focus session to build your history',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Sort sessions by date, newest first
          final sortedSessions = List<FocusSession>.from(sessions)
            ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

          return ListView.builder(
            itemCount: sortedSessions.length,
            itemBuilder: (context, index) {
              final session = sortedSessions[index];
              return _buildSessionCard(
                context,
                ref,
                session,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    WidgetRef ref,
    FocusSession session,
  ) {
    final energyLog =
        ref.watch(sessionEnergyLogProvider(session.id));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: date + status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(session.startedAt),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(session.durationMinutes),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _getStatusIcon(session.completed),
              ],
            ),
            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _buildStatChip(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: _formatDuration(session.durationMinutes),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatChip(
                    icon: Icons.warning_outlined,
                    label: 'Distractions',
                    value: session.distractionsCount.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reflection info if exists
            energyLog.when(
              data: (log) => log != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Energy: ${log.energyEmoji}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (log.reflectionNotes != null &&
                            log.reflectionNotes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            log.reflectionNotes!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
