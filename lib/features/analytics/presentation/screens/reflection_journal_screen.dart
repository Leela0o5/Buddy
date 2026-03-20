import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/energy_log.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../state/analytics_provider.dart';
import '../../../reflection/presentation/state/reflection_provider.dart';

// Screen showing all past reflections and energy logs
class ReflectionJournalScreen extends ConsumerWidget {
  const ReflectionJournalScreen({Key? key}) : super(key: key);

  String _getEnergyEmoji(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return '😴';
      case EnergyLevel.medium:
        return '😐';
      case EnergyLevel.high:
        return '🔥';
    }
  }

  String _getEnergyLabel(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.low:
        return 'Low Energy';
      case EnergyLevel.medium:
        return 'Medium Energy';
      case EnergyLevel.high:
        return 'High Energy';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReflections = ref.watch(allEnergyLogsProvider);
    final mostCommonHelpers = ref.watch(mostCommonHelpersProvider);

    return BaseScaffold(
      title: 'Reflection Journal',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Common helpers section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What helps you focus?',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  mostCommonHelpers.when(
                    data: (helpers) {
                      if (helpers.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Add reflections after sessions to discover patterns',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: helpers
                            .map(
                              (helper) => Chip(
                                avatar: const Icon(Icons.lightbulb, size: 16),
                                label: Text(helper),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            // Past reflections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Past Reflections',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            allReflections.when(
              data: (reflections) {
                if (reflections.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reflections yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Sort by date, newest first
                final sortedReflections = List<EnergyLog>.from(reflections)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedReflections.length,
                  itemBuilder: (context, index) {
                    final reflection = sortedReflections[index];
                    return _buildReflectionCard(context, reflection);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Text('Error: $err'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, EnergyLog reflection) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: date + energy
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(reflection.createdAt),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getEnergyEmoji(reflection.energyLevel),
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      _getEnergyLabel(reflection.energyLevel),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),

            // Reflection notes
            if (reflection.reflectionNotes != null &&
                reflection.reflectionNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                  ),
                ),
                child: Text(
                  reflection.reflectionNotes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
