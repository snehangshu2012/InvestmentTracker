//import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/investment_model.dart';
import '../utils/helpers.dart';
import 'dart:math';

class InvestmentTile extends StatelessWidget {
  final Investment investment;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const InvestmentTile({
    super.key,
    required this.investment,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    //final currentValue = _getCurrentValue();
  final currentValue = investment.getCurrentValue();
    /*double investedAmount;
    if (investment.isSip ||
        investment.type == InvestmentType.recurringDeposit) {
      final monthsInvested =
          DateTime.now().difference(investment.startDate).inDays ~/ 30;
      investedAmount = investment.amount * monthsInvested;
    } else {
      investedAmount = investment.amount;
    }*/
    final investedAmount = investment.investedToDate();

    final gainsLoss = currentValue - investedAmount;
    final isPositive = gainsLoss >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Investment Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getInvestmentColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getInvestmentIcon(),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Investment Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          investment.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          investment.type.displayName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      investment.status.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Financial Information
              Row(
                children: [
                  // Invested Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invested',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyHelper.formatCurrency(investedAmount),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Current Value
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyHelper.formatCurrency(currentValue),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Gains/Loss
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'P&L',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isPositive ? '+' : ''}${CurrencyHelper.formatCurrency(gainsLoss.abs())}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: isPositive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Additional Information Row
              Row(
                children: [
                  // Start Date
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    CurrencyHelper.formatDate(investment.startDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),

                  const Spacer(),

                  // Actions
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(32, 32),
                        foregroundColor: Colors.red,
                      ),
                    ),
                ],
              ),

              // Investment Type Specific Information
              if (_getTypeSpecificInfo().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getTypeSpecificInfo(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getInvestmentColor(BuildContext context) {
    switch (investment.type) {
      case InvestmentType.fixedDeposit:
        return Colors.blue;
      case InvestmentType.recurringDeposit:
        return Colors.lightBlue;
      case InvestmentType.mutualFundEquity:
        return Colors.green;
      case InvestmentType.mutualFundDebt:
        return Colors.orange;
      case InvestmentType.mutualFundHybrid:
        return Colors.amber;
      case InvestmentType.stocks:
        return Colors.red;
      case InvestmentType.bonds:
        return Colors.purple;
      case InvestmentType.goldETF:
      case InvestmentType.goldDigital:
      case InvestmentType.goldPhysical:
        return Colors.yellow.shade700;
      case InvestmentType.realEstate:
        return Colors.brown;
      case InvestmentType.crypto:
        return Colors.deepOrange;
      case InvestmentType.ppf:
        return Colors.teal;
      case InvestmentType.nps:
        return Colors.indigo;
      case InvestmentType.ulip:
        return Colors.cyan;
      case InvestmentType.epf:
        return Colors.blueGrey;
      case InvestmentType.other:
        return Colors.grey;
    }
  }

  IconData _getInvestmentIcon() {
    switch (investment.type) {
      case InvestmentType.fixedDeposit:
      case InvestmentType.recurringDeposit:
        return Icons.account_balance;
      case InvestmentType.mutualFundEquity:
      case InvestmentType.mutualFundDebt:
      case InvestmentType.mutualFundHybrid:
        return Icons.trending_up;
      case InvestmentType.stocks:
        return Icons.show_chart;
      case InvestmentType.bonds:
        return Icons.receipt_long;
      case InvestmentType.goldETF:
      case InvestmentType.goldDigital:
      case InvestmentType.goldPhysical:
        return Icons.star;
      case InvestmentType.realEstate:
        return Icons.home;
      case InvestmentType.crypto:
        return Icons.currency_bitcoin;
      case InvestmentType.ppf:
      case InvestmentType.nps:
        return Icons.savings;
      case InvestmentType.ulip:
        return Icons.security;
      case InvestmentType.epf:
        return Icons.work;
      case InvestmentType.other:
        return Icons.category;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (investment.status) {
      case InvestmentStatus.active:
        return Colors.green.withValues(alpha: 0.1);
      case InvestmentStatus.paused:
        return Colors.orange.withValues(alpha: 0.1);
      case InvestmentStatus.matured:
        return Colors.blue.withValues(alpha: 0.1);
      case InvestmentStatus.closed:
        return Colors.red.withValues(alpha: 0.1);
    }
  }

  String _getTypeSpecificInfo() {
    final data = investment.additionalData;

    switch (investment.type) {
      case InvestmentType.fixedDeposit:
        final bank = data['bankName'] as String?;
        final rate = data['interestRate'] as double?;
        if (bank != null && rate != null) {
          return '$bank • ${rate.toStringAsFixed(1)}% p.a.';
        }
        return bank ?? '';

      case InvestmentType.recurringDeposit:
        final bank = data['bankName'] as String?;
        final monthly = data['monthlyAmount'] as double?;
        if (bank != null && monthly != null) {
          return '$bank • ₹${CurrencyHelper.formatCurrency(monthly)}/month';
        }
        return bank ?? '';

      case InvestmentType.mutualFundEquity:
      case InvestmentType.mutualFundDebt:
      case InvestmentType.mutualFundHybrid:
        final fundName = data['fundName'] as String?;
        final amc = data['amcName'] as String?;
        return [fundName, amc]
            .where((e) => e != null && e.isNotEmpty)
            .join(' • ');

      case InvestmentType.stocks:
        final symbol = data['symbol'] as String?;
        final exchange = data['exchange'] as String?;
        final quantity = data['quantity'] as int?;
        if (symbol != null) {
          final parts = <String>[symbol];
          if (exchange != null) parts.add(exchange);
          if (quantity != null) parts.add('$quantity shares');
          return parts.join(' • ');
        }
        return '';

      case InvestmentType.goldPhysical:
        final weight = data['weight'] as double?;
        final purity = data['purity'] as String?;
        if (weight != null) {
          final parts = <String>['${weight}g'];
          if (purity != null) parts.add(purity);
          return parts.join(' • ');
        }
        return '';

      case InvestmentType.goldETF:
      case InvestmentType.goldDigital:
        final units = data['units'] as double?;
        if (units != null) {
          return '${units.toStringAsFixed(2)} units';
        }
        return '';

      case InvestmentType.realEstate:
        final location = data['location'] as String?;
        final propertyType = data['propertyType'] as String?;
        return [propertyType, location]
            .where((e) => e != null && e.isNotEmpty)
            .join(' • ');

      case InvestmentType.crypto:
        final cryptoName = data['cryptoName'] as String?;
        final symbol = data['symbol'] as String?;
        final quantity = data['quantity'] as double?;
        if (cryptoName != null) {
          final parts = <String>[cryptoName];
          if (symbol != null) parts.add('($symbol)');
          if (quantity != null) parts.add('${quantity.toStringAsFixed(4)}');
          return parts.join(' • ');
        }
        return '';

      case InvestmentType.bonds:
        final bondName = data['bondName'] as String?;
        final bondType = data['bondType'] as String?;
        return [bondType, bondName]
            .where((e) => e != null && e.isNotEmpty)
            .join(' • ');

      case InvestmentType.ppf:
        final institution = data['institution'] as String?;
        return institution ?? '';

      case InvestmentType.nps:
        final tier = data['tier'] as String?;
        return tier ?? '';

      case InvestmentType.ulip:
        final company = data['insuranceCompany'] as String?;
        final policyNumber = data['policyNumber'] as String?;
        return [company, policyNumber]
            .where((e) => e != null && e.isNotEmpty)
            .join(' • ');

      case InvestmentType.epf:
        final employer = data['employerName'] as String?;
        return employer ?? '';

      case InvestmentType.other:
        final description = data['description'] as String?;
        return description ?? '';
    }
  }
}
