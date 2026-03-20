import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/base_scaffold.dart';
import '../../../../config/constants.dart';
import '../state/analytics_provider.dart';

// Analytics and insights dashboard
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  String _formatMinutesToHours(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  String _formatHour(int? hour) {
    if (hour == null) return 'N/A';
    return '$hour:00 - ${hour + 1}:00';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScaffold(
      title: AppStrings.analyticsTab,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key metrics
            _buildMetricsGrid(context, ref),
            const SizedBox(height: 24),

            // Focus time chart placeholder
            _buildChartSection(context, ref),
            const SizedBox(height: 24),

            // Insights section
            _buildInsightsSection(context, ref),
          ],
        ),
      ),
    );
  }

  // Main metrics grid
  Widget _buildMetricsGrid(BuildContext context, WidgetRef ref) {
    final weeklyFocusTime = ref.watch(weeklyFocusTimeProvider);
    final todaySessionCount = ref.watch(todaySessionCountProvider);
    final completionRate = ref.watch(completionRateProvider);
    final distractionRate = ref.watch(averageDistractionRateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            weeklyFocusTime.when(
              data: (minutes) => _buildMetricCard(
                context,
                title: AppStrings.totalFocusTime,
                value: _formatMinutesToHours(minutes),
                icon: Icons.timer_outlined,
              ),
              loading: () => _buildMetricCard(
                context,
                title: AppStrings.totalFocusTime,
                value: '...',
                icon: Icons.timer_outlined,
              ),
              error: (_, __) => _buildMetricCard(
                context,
                title: AppStrings.totalFocusTime,
                value: 'Error',
                icon: Icons.timer_outlined,
              ),
            ),
            todaySessionCount.when(
              data: (count) => _buildMetricCard(
                context,
                title: AppStrings.sessionsCompleted,
                value: count.toString(),
                icon: Icons.check_circle_outline,
              ),
              loading: () => _buildMetricCard(
                context,
                title: AppStrings.sessionsCompleted,
                value: '...',
                icon: Icons.check_circle_outline,
              ),
              error: (_, __) => _buildMetricCard(
                context,
                title: AppStrings.sessionsCompleted,
                value: 'Error',
                icon: Icons.check_circle_outline,
              ),
            ),
            completionRate.when(
              data: (rate) => _buildMetricCard(
                context,
                title: 'Completion',
                value: '${rate.toStringAsFixed(0)}%',
                icon: Icons.local_fire_department_outlined,
              ),
              loading: () => _buildMetricCard(
                context,
                title: 'Completion',
                value: '...',
                icon: Icons.local_fire_department_outlined,
              ),
              error: (_, __) => _buildMetricCard(
                context,
                title: 'Completion',
                value: 'Error',
                icon: Icons.local_fire_department_outlined,
              ),
            ),
            distractionRate.when(
              data: (rate) => _buildMetricCard(
                context,
                title: AppStrings.distractionRate,
                value: rate.toStringAsFixed(1),
                icon: Icons.warning_outlined,
              ),
              loading: () => _buildMetricCard(
                context,
                title: AppStrings.distractionRate,
                value: '...',
                icon: Icons.warning_outlined,
              ),
              error: (_, __) => _buildMetricCard(
                context,
                title: AppStrings.distractionRate,
                value: 'Error',
                icon: Icons.warning_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Individual metric card
  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Focus time chart section
  Widget _buildChartSection(BuildContext context, WidgetRef ref) {
    final weeklyHistory = ref.watch(weeklyFocusTimeHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Focus Time (Last 7 Days)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        weeklyHistory.when(
          data: (history) => _buildSimpleChart(context, history),
          loading: () => _buildChartPlaceholder(context, 'Loading...'),
          error: (_, __) => _buildChartPlaceholder(context, 'Error loading data'),
        ),
      ],
    );
  }

  // Simple bar chart visualization
  Widget _buildSimpleChart(BuildContext context, List<int> dailyValues) {
    final maxValue = dailyValues.isEmpty ? 1 : dailyValues.reduce((a, b) => a > b ? a : b);
    final normalizedMax = (maxValue / 30).ceil() * 30; // Round up to nearest 30

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(dailyValues.length, (index) {
              final value = dailyValues[index];
              final percentage = normalizedMax == 0 ? 0 : (value / normalizedMax);
              final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

              return Column(
                children: [
                  Container(
                    width: 30,
                    height: (100.0 * percentage),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Minutes per day',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Chart placeholder
  Widget _buildChartPlaceholder(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  // Insights section
  Widget _buildInsightsSection(BuildContext context, WidgetRef ref) {
    final bestFocusHour = ref.watch(bestFocusHourProvider);
    final burnoutRisk = ref.watch(burnoutRiskProvider);
    final focusDrift = ref.watch(focusDriftProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        bestFocusHour.when(
          data: (hour) => _buildInsightCard(
            context,
            icon: Icons.sunny,
            title: 'Best Focus Time',
            description: hour != null
                ? 'You focus best around ${_formatHour(hour)}'
                : 'Start sessions to find your best focus time',
          ),
          loading: () => _buildInsightCard(
            context,
            icon: Icons.sunny,
            title: 'Best Focus Time',
            description: 'Loading...',
          ),
          error: (_, __) => _buildInsightCard(
            context,
            icon: Icons.sunny,
            title: 'Best Focus Time',
            description: 'Error',
          ),
        ),
        const SizedBox(height: 12),
        burnoutRisk.when(
          data: (hasRisk) => hasRisk
              ? _buildWarningCard(
                  context,
                  icon: Icons.warning,
                  title: '⚠️ Burnout Risk',
                  description:
                      'You\'ve completed 4+ sessions in 2 hours. Take a break!',
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        burnoutRisk.maybeWhen(
          data: (hasRisk) => !hasRisk
              ? focusDrift.maybeWhen(
                  data: (drift) => drift
                      ? _buildWarningCard(
                          context,
                          icon: Icons.info,
                          title: 'Focus Drift Detected',
                          description:
                              'Try shorter 5-10 min sessions for better completion.',
                        )
                      : _buildInsightCard(
                          context,
                          icon: Icons.thumb_up,
                          title: 'Great Job!',
                          description:
                              'You\'re maintaining consistent focus. Keep it up! 🎯',
                        ),
                  orElse: () => const SizedBox.shrink(),
                )
              : const SizedBox.shrink(),
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  // Insight card
  Widget _buildInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Warning card (burnout/focus drift)
  Widget _buildWarningCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}