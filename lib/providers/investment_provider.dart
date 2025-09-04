import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment_model.dart';
import '../services/local_db_service.dart';
import '../utils/helpers.dart';

// Provider for LocalDbService
final localDbServiceProvider = Provider<LocalDbService>((ref) {
  return LocalDbService.instance;
});

// Investment list provider
final investmentListProvider =
    StateNotifierProvider<InvestmentNotifier, AsyncValue<List<Investment>>>(
        (ref) {
  return InvestmentNotifier(ref.read(localDbServiceProvider));
});

// Investment statistics provider
final investmentStatsProvider = Provider<InvestmentStats>((ref) {
  final investmentsAsync = ref.watch(investmentListProvider);
  return investmentsAsync.when(
    data: (investments) => InvestmentStats.fromInvestments(investments),
    loading: () => InvestmentStats.empty(),
    error: (error, stackTrace) => InvestmentStats.empty(),
  );
});

// Portfolio allocation provider
final portfolioAllocationProvider =
    Provider<Map<String, double>>((ref) {
  final investmentsAsync = ref.watch(investmentListProvider);
  return investmentsAsync.when(
    data: (investments) {
      final allocation = <String, double>{};
      final totalValue =
          investments.fold(0.0, (sum, inv) => sum + inv.getCurrentValue());
      if (totalValue == 0) return allocation;

      for (final inv in investments) {
        final cat = inv.type.category;
        final val = inv.getCurrentValue();
        allocation[cat] = (allocation[cat] ?? 0) + val;
      }

      allocation.updateAll((_, v) => (v / totalValue) * 100);
      return allocation;
    },
    loading: () => <String, double>{},
    error: (_, __) => <String, double>{},
  );
});

// Investment filter provider
final investmentFilterProvider =
    StateProvider<InvestmentFilter>((_) => InvestmentFilter());

// Filtered investments provider
final filteredInvestmentsProvider =
    Provider<List<Investment>>((ref) {
  final investmentsAsync = ref.watch(investmentListProvider);
  final filter = ref.watch(investmentFilterProvider);
  return investmentsAsync.when(
    data: (investments) {
      var filtered = investments;

      if (filter.type != null) {
        filtered = filtered.where((inv) => inv.type == filter.type).toList();
      }

      if (filter.status != null) {
        filtered =
            filtered.where((inv) => inv.status == filter.status).toList();
      }

      if (filter.searchQuery.isNotEmpty) {
        final q = filter.searchQuery.toLowerCase();
        filtered =
            filtered.where((inv) => inv.name.toLowerCase().contains(q)).toList();
      }

      switch (filter.sortBy) {
        case InvestmentSortBy.name:
          filtered.sort((a, b) => a.name.compareTo(b.name));
          break;
        case InvestmentSortBy.amount:
          filtered.sort((a, b) => b.amount.compareTo(a.amount));
          break;
        case InvestmentSortBy.date:
          filtered.sort((a, b) => b.startDate.compareTo(a.startDate));
          break;
        case InvestmentSortBy.gains:
          filtered.sort(
              (a, b) => b.getGainsLoss().compareTo(a.getGainsLoss()));
          break;
      }

      if (filter.sortDescending) {
        filtered = filtered.reversed.toList();
      }

      return filtered;
    },
    loading: () => const [],
    error: (_, __) => const [],
  );
});

class InvestmentNotifier
    extends StateNotifier<AsyncValue<List<Investment>>> {
  final LocalDbService _dbService;

  InvestmentNotifier(this._dbService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    await _dbService.init();
    await loadInvestments();
  }

  Future<void> loadInvestments() async {
    try {
      state = const AsyncValue.loading();
      final investments = _dbService.getAllInvestments();
      state = AsyncValue.data(investments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addInvestment(Investment inv) async {
    try {
      await _dbService.addInvestment(inv);
      await loadInvestments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateInvestment(Investment inv) async {
    try {
      await _dbService.updateInvestment(inv);
      await loadInvestments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteInvestment(String id) async {
    try {
      await _dbService.deleteInvestment(id);
      await loadInvestments();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => loadInvestments();
}

class InvestmentStats {
  final double totalPortfolioValue;
  final double totalInvestedAmount;
  final double totalGainsLoss;
  final double gainsLossPercentage;
  final int totalInvestments;
  final int activeInvestments;
  final int maturedInvestments;

  InvestmentStats({
    required this.totalPortfolioValue,
    required this.totalInvestedAmount,
    required this.totalGainsLoss,
    required this.gainsLossPercentage,
    required this.totalInvestments,
    required this.activeInvestments,
    required this.maturedInvestments,
  });

  factory InvestmentStats.fromInvestments(List<Investment> investments) {
    final totalValue =
        investments.fold(0.0, (sum, inv) => sum + inv.getCurrentValue());

    // Single source of truth for invested across the app
    final invested = investments.fold(
        0.0, (sum, inv) => sum + inv.investedToDate(asOf: DateTime.now()));

    final gainsLoss = totalValue - invested;
    final percent = invested > 0 ? (gainsLoss / invested) * 100 : 0.0;

    return InvestmentStats(
      totalPortfolioValue: totalValue,
      totalInvestedAmount: invested,
      totalGainsLoss: gainsLoss,
      gainsLossPercentage: percent,
      totalInvestments: investments.length,
      activeInvestments:
          investments.where((inv) => inv.status == InvestmentStatus.active).length,
      maturedInvestments:
          investments.where((inv) => inv.status == InvestmentStatus.matured).length,
    );
  }

  factory InvestmentStats.empty() => InvestmentStats(
        totalPortfolioValue: 0,
        totalInvestedAmount: 0,
        totalGainsLoss: 0,
        gainsLossPercentage: 0,
        totalInvestments: 0,
        activeInvestments: 0,
        maturedInvestments: 0,
      );

  String get formattedTotalPortfolioValue =>
      CurrencyHelper.formatAmount(totalPortfolioValue);
  String get formattedTotalInvestedAmount =>
      CurrencyHelper.formatAmount(totalInvestedAmount);
  String get formattedTotalGainsLoss =>
      CurrencyHelper.formatAmount(totalGainsLoss);
  String get compactPortfolioValue =>
      CurrencyHelper.formatCompactAmount(totalPortfolioValue);

  bool get hasGains => totalGainsLoss > 0;
  bool get hasLoss => totalGainsLoss < 0;
}

class InvestmentFilter {
  final InvestmentType? type;
  final InvestmentStatus? status;
  final String searchQuery;
  final InvestmentSortBy sortBy;
  final bool sortDescending;

  InvestmentFilter({
    this.type,
    this.status,
    this.searchQuery = '',
    this.sortBy = InvestmentSortBy.date,
    this.sortDescending = false,
  });

  InvestmentFilter copyWith({
    InvestmentType? type,
    InvestmentStatus? status,
    String? searchQuery,
    InvestmentSortBy? sortBy,
    bool? sortDescending,
  }) {
    return InvestmentFilter(
      type: type ?? this.type,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}

enum InvestmentSortBy { name, amount, date, gains }

extension InvestmentSortByExtension on InvestmentSortBy {
  String get displayName {
    switch (this) {
      case InvestmentSortBy.name:
        return 'Name';
      case InvestmentSortBy.amount:
        return 'Amount';
      case InvestmentSortBy.date:
        return 'Date';
      case InvestmentSortBy.gains:
        return 'Gains/Loss';
    }
  }
}
