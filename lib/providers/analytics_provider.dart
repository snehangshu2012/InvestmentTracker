// analytics_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment_model.dart';
import '../models/settings_model.dart';
import 'investment_provider.dart';

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final investmentsAsync = ref.watch(investmentListProvider);
  return investmentsAsync.when(
    data: (investments) => AnalyticsData.fromInvestments(investments),
    loading: () => AnalyticsData.empty(),
    error: (_, __) => AnalyticsData.empty(),
  );
});

final selectedTimePeriodProvider =
    StateProvider<TimePeriod>((ref) => TimePeriod.all);

final filteredAnalyticsProvider = Provider<AnalyticsData>((ref) {
  final analytics = ref.watch(analyticsProvider);
  final timePeriod = ref.watch(selectedTimePeriodProvider);
  return analytics.filterByTimePeriod(timePeriod);
});

/// Monthly SIP (includes RD treated as recurring)
final monthlySIPProvider = Provider<double>((ref) {
  final investmentsAsync = ref.watch(investmentListProvider);
  return investmentsAsync.when(
    data: (investments) => investments
        .where((inv) =>
            (inv.isSip || inv.type == InvestmentType.recurringDeposit) &&
            inv.status == InvestmentStatus.active)
        .fold(0.0, (sum, inv) => sum + inv.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

class AnalyticsData {
  final double totalReturns;
  final Investment? bestPerformer;
  final Investment? worstPerformer;
  final List<Investment> investments;
  final Map<String, double> categoryPerformance;
  final List<PortfolioPoint> portfolioHistory;

  AnalyticsData({
    required this.totalReturns,
    this.bestPerformer,
    this.worstPerformer,
    required this.investments,
    required this.categoryPerformance,
    required this.portfolioHistory,
  });

  factory AnalyticsData.fromInvestments(List<Investment> investments) {
    if (investments.isEmpty) return AnalyticsData.empty();

    final totalReturns =
        investments.fold(0.0, (sum, inv) => sum + inv.getGainsLoss());

    Investment? bestPerformer;
    Investment? worstPerformer;
    double bestPerformance = double.negativeInfinity;
    double worstPerformance = double.infinity;

    for (final inv in investments) {
      final perf = inv.getGainsLossPercentage();
      if (perf > bestPerformance) {
        bestPerformance = perf;
        bestPerformer = inv;
      }
      if (perf < worstPerformance) {
        worstPerformance = perf;
        worstPerformer = inv;
      }
    }

    // Category performance using single source of truth for invested
    final Map<String, double> categoryCurrent = {};
    final Map<String, double> categoryInvested = {};

    for (final inv in investments) {
      final category = inv.type.category;
      final current = inv.getCurrentValue();
      final invested = inv.investedToDate(asOf: DateTime.now());

      categoryCurrent[category] = (categoryCurrent[category] ?? 0) + current;
      categoryInvested[category] = (categoryInvested[category] ?? 0) + invested;
    }

    final Map<String, double> categoryPerformance = {};
    categoryCurrent.forEach((category, curr) {
      final inv = categoryInvested[category] ?? 0;
      if (inv > 0) {
        categoryPerformance[category] = ((curr - inv) / inv) * 100;
      }
    });

    final history = _generatePortfolioHistory(investments);

    return AnalyticsData(
      totalReturns: totalReturns,
      bestPerformer: bestPerformer,
      worstPerformer: worstPerformer,
      investments: investments,
      categoryPerformance: categoryPerformance,
      portfolioHistory: history,
    );
  }

  factory AnalyticsData.empty() => AnalyticsData(
        totalReturns: 0,
        investments: [],
        categoryPerformance: {},
        portfolioHistory: [],
      );

  static List<PortfolioPoint> _generatePortfolioHistory(
      List<Investment> investments) {
    if (investments.isEmpty) return [];
    final now = DateTime.now();
    final points = <PortfolioPoint>[];

    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, now.day);
      double totalValue = 0;

      for (final inv in investments) {
        if (!inv.startDate.isAfter(date)) {
          final monthsHeld = date.difference(inv.startDate).inDays ~/ 30;
          if (monthsHeld > 0) {
            // Simple proportional history placeholder
            totalValue += inv.getCurrentValue() *
                (monthsHeld /
                    (DateTime.now().difference(inv.startDate).inDays ~/ 30));
          }
        }
      }

      points.add(PortfolioPoint(date: date, value: totalValue));
    }

    return points;
  }

  AnalyticsData filterByTimePeriod(TimePeriod period) {
    if (period == TimePeriod.all) return this;
    final cutoff = DateTime.now().subtract(Duration(days: period.months * 30));
    final filtered =
        investments.where((inv) => inv.startDate.isAfter(cutoff)).toList();
    return AnalyticsData.fromInvestments(filtered);
  }
}

class PortfolioPoint {
  final DateTime date;
  final double value;
  PortfolioPoint({required this.date, required this.value});
}

class InvestmentPerformance {
  final String name;
  final InvestmentType type;
  final double invested;
  final double current;

  InvestmentPerformance({
    required this.name,
    required this.type,
    required this.invested,
    required this.current,
  });
}

final investmentPerformanceProvider =
    Provider<List<InvestmentPerformance>>((ref) {
  final investmentsAsync = ref.watch(investmentListProvider);

  return investmentsAsync.when(
    data: (investments) {
      final now = DateTime.now();
      return investments.map((inv) {
        final invested = inv.investedToDate(asOf: now); // SSOT
        final current = inv.getCurrentValue();
        return InvestmentPerformance(
          name: inv.name,
          type: inv.type,
          invested: invested,
          current: current,
        );
      }).toList();
    },
    loading: () => const [],
    error: (_, __) => const [],
  );
});
