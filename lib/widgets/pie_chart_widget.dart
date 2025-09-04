import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> allocation;

  const PieChartWidget({
    super.key,
    required this.allocation,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

@override
Widget build(BuildContext context) {
  if (widget.allocation.isEmpty) {
    return const Center(child: Text('No data available'));
  }

  // Define a fixed height for the pie chart container
  double chartHeight = 250;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: chartHeight,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            // Set centerSpaceRadius to about 30-40% of chartHeight for good visuals
            centerSpaceRadius: chartHeight * 0.1,
            sections: _buildPieChartSections(),
          ),
        ),
      ),
      const SizedBox(height: 16),
      _buildLegend(),
    ],
  );
}


  List<PieChartSectionData> _buildPieChartSections() {
    final colors = _getCategoryColors();
    final entries = widget.allocation.entries.toList();

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      final widgetSize = isTouched ? 55.0 : 40.0;

      return PieChartSectionData(
        color: colors[data.key] ?? Colors.grey,
        value: data.value,
        title: '${data.value.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        badgeWidget: isTouched ? _buildBadge(data.key, widgetSize) : null,
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }

  Widget _buildBadge(String category, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(category),
          color: Theme.of(context).colorScheme.primary,
          size: size * 0.6,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final colors = _getCategoryColors();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.allocation.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors[entry.key] ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key} (${entry.value.toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Map<String, Color> _getCategoryColors() {
    return {
      'Equity': Colors.blue,
      'Debt': Colors.green,
      'Hybrid': Colors.orange,
      'Gold': Colors.amber,
      'Real Estate': Colors.brown,
      'Crypto': Colors.purple,
      'Retirement': Colors.indigo,
      'Other': Colors.grey,
    };
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Equity':
        return Icons.trending_up;
      case 'Debt':
        return Icons.account_balance;
      case 'Hybrid':
        return Icons.balance;
      case 'Gold':
        return Icons.star;
      case 'Real Estate':
        return Icons.home;
      case 'Crypto':
        return Icons.currency_bitcoin;
      case 'Retirement':
        return Icons.elderly;
      case 'Other':
        return Icons.category;
      default:
        return Icons.pie_chart;
    }
  }
}
