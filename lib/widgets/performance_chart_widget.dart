import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../providers/analytics_provider.dart';
import '../models/settings_model.dart';

class PerformanceChartWidget extends StatelessWidget {
  final List<PortfolioPoint> portfolioHistory;
  final TimePeriod selectedPeriod;
  final Function(TimePeriod) onPeriodChanged;

  const PerformanceChartWidget({
    super.key,
    required this.portfolioHistory,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Title
                Expanded(
                  flex: 2,
                  child: Text(
                    'Portfolio Performance',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),

                // Scrollable selector
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: TimePeriod.values.map((period) {
                          final isSelected = period == selectedPeriod;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => onPeriodChanged(period),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                child: Text(
                                  period.displayName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: portfolioHistory.isEmpty
                  ? const Center(child: Text('No data available'))
                  : LineChart(_buildLineChartData(context)),
            ),
          ],
        ),
      ),
    );
  }

/*  Widget _buildTimePeriodSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: TimePeriod.values.map((period) {
            final isSelected = period == selectedPeriod;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onPeriodChanged(period),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  child: Text(
                    period.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
*/
  LineChartData _buildLineChartData(BuildContext context) {
    final spots = portfolioHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          strokeWidth: 1,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 &&
                  value.toInt() < portfolioHistory.length) {
                final date = portfolioHistory[value.toInt()].date;
                return Text(
                  '${date.month}/${date.year.toString().substring(2)}',
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatCurrency(value),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Theme.of(context).colorScheme.primary,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '₹${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₹${value.toStringAsFixed(0)}';
  }
}
