import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import '../providers/investment_provider.dart';
import '../widgets/performance_chart_widget.dart';
import '../utils/helpers.dart';
import '../models/investment_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(filteredAnalyticsProvider);
    final selectedPeriod = ref.watch(selectedTimePeriodProvider);
    final monthlySIP = ref.watch(monthlySIPProvider);

    // 1. Fetch the adjusted investment performance list
    final perfList = ref.watch(investmentPerformanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(investmentListProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(investmentListProvider),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStats(context, analytics, monthlySIP),
              const SizedBox(height: 24),
              PerformanceChartWidget(
                portfolioHistory: analytics.portfolioHistory,
                selectedPeriod: selectedPeriod,
                onPeriodChanged: (period) {
                  ref.read(selectedTimePeriodProvider.notifier).state = period;
                },
              ),
              const SizedBox(height: 24),
              _buildAssetAllocationAnalysis(context, analytics),
              const SizedBox(height: 24),
              _buildInvestmentPerformanceTable(context, perfList),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(
      BuildContext context, AnalyticsData analytics, double monthlySIP) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Returns',
                CurrencyHelper.formatCompactAmount(analytics.totalReturns),
                Icons.trending_up,
                analytics.totalReturns >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                context,
                'Monthly SIP',
                CurrencyHelper.formatCompactAmount(monthlySIP),
                Icons.repeat,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPerformerCard(
                context,
                'Best Performer',
                analytics.bestPerformer,
                true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPerformerCard(
                context,
                'Worst Performer',
                analytics.worstPerformer,
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerCard(
      BuildContext context, String title, Investment? investment, bool isBest) {
    final color = isBest ? Colors.green : Colors.red;
    final icon = isBest ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (investment != null) ...[
              Text(
                investment.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${investment.getGainsLossPercentage().toStringAsFixed(2)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ] else ...[
              Text(
                'No data',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.outline),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssetAllocationAnalysis(
      BuildContext context, AnalyticsData analytics) {
    if (analytics.categoryPerformance.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No allocation data available',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Performance',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...analytics.categoryPerformance.entries.map((e) {
              final isPositive = e.value >= 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(child: Text(e.key)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.green.withValues(alpha: 0.1)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isPositive
                              ? Icons.trending_up
                              : Icons.trending_down),
                          const SizedBox(width: 4),
                          Text(
                            '${e.value.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: isPositive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 3. New Investment Performance Table
  Widget _buildInvestmentPerformanceTable(
      BuildContext context, List<InvestmentPerformance> list) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Invested')),
            DataColumn(label: Text('Current')),
          ],
          rows: list.map((p) {
            return DataRow(cells: [
              DataCell(Text(p.name)),
              DataCell(Text(p.type.category)),
              DataCell(Text(CurrencyHelper.formatCompactAmount(p.invested))),
              DataCell(Text(CurrencyHelper.formatCompactAmount(p.current))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
