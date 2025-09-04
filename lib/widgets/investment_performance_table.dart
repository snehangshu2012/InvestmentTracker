import 'package:flutter/material.dart';
import '../models/investment_model.dart';
import '../utils/helpers.dart';

class InvestmentPerformanceTable extends StatelessWidget {
  final List<Investment> investments;

  const InvestmentPerformanceTable({
    super.key,
    required this.investments,
  });

  @override
  Widget build(BuildContext context) {
    if (investments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.table_rows,
                  size: 48,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No investments to display',
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
            Text(
              'Investment Performance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Invested')),
                  DataColumn(label: Text('Current')),
                  DataColumn(label: Text('Gain/Loss')),
                  DataColumn(label: Text('Return %')),
                ],
                rows: investments.map((investment) {
                  final currentValue = investment.getCurrentValue();
                  final gainsLoss = investment.getGainsLoss();
                  final percentage = investment.getGainsLossPercentage();
                  final isGain = gainsLoss >= 0;

                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 100,
                          child: Text(
                            investment.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _getCategoryColor(investment.type.category)
                                .withValues(alpha: 0.1),
                          ),
                          child: Text(
                            investment.type.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getCategoryColor(investment.type.category),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          investment.compactAmount,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Text(
                          CurrencyHelper.formatCompactAmount(currentValue),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: (isGain ? Colors.green : Colors.red)
                                .withValues(alpha: 0.1),
                          ),
                          child: Text(
                            CurrencyHelper.formatAmount(gainsLoss),
                            style: TextStyle(
                              color: isGain ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: (isGain ? Colors.green : Colors.red)
                                .withValues(alpha: 0.1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isGain ? Icons.trending_up : Icons.trending_down,
                                size: 14,
                                color: isGain ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${percentage.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  color: isGain ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'equity':
        return Colors.blue;
      case 'debt':
        return Colors.green;
      case 'gold':
        return Colors.amber;
      case 'real estate':
        return Colors.brown;
      case 'crypto':
        return Colors.purple;
      case 'hybrid':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
