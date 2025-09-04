import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../utils/helpers.dart';
part 'investment_model.g.dart';

@HiveType(typeId: 0)
class Investment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  InvestmentType type;

  @HiveField(3)
  double
      amount; // for lumpsum or monthly SIP amount (depending on investmentMode)

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime? maturityDate;

  @HiveField(6)
  InvestmentStatus status;

  @HiveField(7)
  Map<String, dynamic>
      additionalData; // can include current NAV, investmentMode, etc.

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  Investment({
    String? id,
    required this.name,
    required this.type,
    required this.amount,
    required this.startDate,
    this.maturityDate,
    this.status = InvestmentStatus.active,
    Map<String, dynamic>? additionalData,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        additionalData = additionalData ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Returns true if this investment is SIP
  bool get isSip =>
      (additionalData['investmentMode'] as String?)?.toLowerCase() == 'sip';

  /// SIP calculation using formula: M = P * { ((1 + i)^n - 1) / i } * (1 + i)
/*  double calculateSipCurrentValue({
    required double monthlySipAmount,
    required DateTime sipStartDate,
    required double currentNav,
    double annualReturnRate = 0.08,
    required InvestmentType investmentType,
    double? totalUnits, // New parameter for actual units held (nullable)
  }) {
    final now = DateTime.now();
    final monthsInvested =
        (now.year - sipStartDate.year) * 12 + now.month - sipStartDate.month;
    if (monthsInvested <= 0) return 0.0;

    if (investmentType == InvestmentType.goldETF ||
        investmentType == InvestmentType.goldDigital) {
      if (totalUnits != null && totalUnits > 0) {
        // Use actual units to calculate current value
        return totalUnits * currentNav;
      } else {
        // Fallback: estimate units with average NAV (80% of current NAV)
        final totalInvested = monthlySipAmount * monthsInvested;
        final averagePurchaseNav = currentNav * 0.8;
        final estimatedUnits = totalInvested / averagePurchaseNav;
        return estimatedUnits * currentNav;
      }
    } else {
      // Mutual Fund SIP: Standard compounding formula
      final monthlyRate = annualReturnRate / 12;
      if (monthlyRate == 0) return monthlySipAmount * monthsInvested;

      final factor = (pow(1 + monthlyRate, monthsInvested) - 1) / monthlyRate;
      return monthlySipAmount * factor * (1 + monthlyRate);
    }
  }*/

  // Get formatted amount string
  String get formattedAmount {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String get compactAmount {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formattedAmount;
  }

  String get formattedStartDate {
    return DateFormat('dd MMM yyyy').format(startDate);
  }

  String get formattedMaturityDate {
    if (maturityDate == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(maturityDate!);
  }

  // Calculate current value
  double getCurrentValue() {
    print('=== InvestmentTile _getCurrentValue Debug ===');
    print('Investment name: $name');
    print('Is SIP: $isSip');
    print('Start Date: $startDate');
    print('Amount: $amount');
    print('Additional Data: $additionalData');

    switch (type) {
      case InvestmentType.fixedDeposit:
        final rate = additionalData['interestRate'] as double? ?? 0.0;
        final compoundingFreqStr =
            additionalData['compoundingFreq'] as String? ?? 'Quarterly';
        final compoundingFreq = compoundingFreqToInt(compoundingFreqStr);
        final years = DateTime.now().difference(startDate).inDays / 365.25;
        return amount *
            pow(1 + (rate / 100) / compoundingFreq, compoundingFreq * years);

      case InvestmentType.recurringDeposit:
        {
          final double P = amount; // monthly deposit
          final double R = (additionalData['interestRate'] as double? ?? 0.0) /
              100; // annual rate as decimal
          final int N = compoundingFreqToInt(
              additionalData['compoundingFreq'] as String? ?? 'Quarterly');

          // Get maturity date from additionalData
          final maturityDate = additionalData['maturityDate'] as DateTime?;
          final endDate =
              (maturityDate != null)
                  ? maturityDate
                  : DateTime.now();

          // Calculate total months from start to end
          int totalMonths = (endDate.year - startDate.year) * 12 +
              (endDate.month - startDate.month);
          if (endDate.day < startDate.day) totalMonths--;
          totalMonths = totalMonths < 0 ? 0 : totalMonths;

          if (P <= 0 || R <= 0 || totalMonths <= 0) return P * totalMonths;

          double totalValue = 0.0;

          // Apply RD formula: A = P*(1+R/N)^(Nt) for each monthly deposit
          for (int month = 1; month <= totalMonths; month++) {
            final double t = (totalMonths - month + 1) /
                12.0; // time in years for this deposit
            final double A = P * pow(1 + R / N, N * t); // Standard RD formula
            totalValue += A;
          }

          return totalValue;
        }
      case InvestmentType.ppf:
        final annualContribution = amount;
        final rawRate = additionalData['interestRate'] as double? ?? 7.1;
        final rate = rawRate / 100.0;
        final now = DateTime.now();
        if (annualContribution <= 0 || rate <= 0 || now.isBefore(startDate))
          return 0.0;
        final totalYearsElapsed = now.difference(startDate).inDays / 365.25;
        final fullYears = totalYearsElapsed.floor();
        final fractionalYear = totalYearsElapsed - fullYears;
        double maturityValue = 0.0;
        for (int i = 0; i < fullYears; i++) {
          final yearsCompounded = totalYearsElapsed - i;
          maturityValue += annualContribution * pow(1 + rate, yearsCompounded);
        }
        if (fractionalYear > 0) {
          maturityValue += annualContribution * (1 + rate * fractionalYear);
        }
        return maturityValue;

      case InvestmentType.nps:
        final lumpSum = amount;
        final now = DateTime.now();
        if (lumpSum <= 0 || now.isBefore(startDate)) return 0.0;

        final yearsElapsed = now.difference(startDate).inDays / 365.25;

        // Map lifecycle fund to expected annual return rates
        final lifecycleFund =
            (additionalData['lifecycleFund'] as String?)?.toLowerCase() ??
                'lc75';

        double rate;
        switch (lifecycleFund) {
          case 'lc75':
            rate = 0.11; // 11%
            break;
          case 'lc50':
            rate = 0.095; // 9.5%
            break;
          case 'lc25':
            rate = 0.08; // 8%
            break;
          case 'corporatebond':
            rate = 0.07; // 7%
            break;
          default:
            rate = 0.08; // default 8%
        }

        // Simple lump sum compounding formula
        final maturityValue = lumpSum * pow(1 + rate, yearsElapsed);

        return maturityValue;

      // Equity and Stock Investments
      case InvestmentType.mutualFundEquity:
      case InvestmentType.mutualFundDebt:
      case InvestmentType.mutualFundHybrid:
      case InvestmentType.stocks:
        final units = parseDouble(additionalData['units']);
        final currentNAV = parseDouble(additionalData['currentNAV']);
        return units * currentNAV;

      // Gold Investments
      case InvestmentType.goldETF:
      case InvestmentType.goldDigital:
        final units = parseDouble(additionalData['units']);
        final currentPrice = parseDouble(additionalData['currentNAV']);
        return units * currentPrice;

      case InvestmentType.goldPhysical:
        final grams = parseDouble(additionalData['weight']);
        final currentPricePerGram = parseDouble(additionalData['currentNAV']);
        return grams * currentPricePerGram;
      //real estate
      case InvestmentType.realEstate:
        final area = parseDouble(additionalData['area']);
        final currentPrice = parseDouble(additionalData['currentNAV']);
        return area * currentPrice;

      case InvestmentType.bonds:
        {
          final double quantity = additionalData['quantity'] is int
              ? (additionalData['quantity'] as int).toDouble()
              : parseDouble(additionalData['quantity']);
          final double faceValue = parseDouble(additionalData['faceValue']);
          final double couponRate =
              parseDouble(additionalData['couponRate']); // annual %
          final DateTime? purchaseDate =
              additionalData['purchaseDate'] as DateTime?;
          final DateTime? maturityDate =
              additionalData['maturityDate'] as DateTime?;
          final double pricePct =
              parseDouble(additionalData['currentMarketPrice']); // % of par
          final String freqStr =
              (additionalData['couponFrequency'] as String?)?.toLowerCase() ??
                  'annual';
          final bool isCleanPrice = (additionalData['isCleanPrice'] as bool?) ??
              true; // default to clean price

          if (quantity <= 0 ||
              faceValue <= 0 ||
              couponRate <= 0 ||
              purchaseDate == null ||
              maturityDate == null) {
            return 0.0;
          }

          final DateTime now = DateTime.now();
          final DateTime valuationDate =
              now.isAfter(maturityDate) ? maturityDate : now;

          // Determine coupon payments per year
          final int paymentsPerYear;
          switch (freqStr) {
            case 'semi-annual':
            case 'semiannual':
              paymentsPerYear = 2;
              break;
            case 'quarterly':
              paymentsPerYear = 4;
              break;
            case 'annual':
            default:
              paymentsPerYear = 1;
              break;
          }

          // Days in one coupon period
          final double daysInPeriod = 365.25 / paymentsPerYear;

          // Total days elapsed between purchase and valuation, capped at maturity
          final int totalElapsedDays =
              valuationDate.difference(purchaseDate).inDays;
          if (totalElapsedDays <= 0) {
            // Valuation date ≤ purchase date, value is principal at price
            final principal = quantity * faceValue;
            return principal * (pricePct / 100.0);
          }

          // Number of full coupon periods elapsed
          final int periodsElapsed = (totalElapsedDays / daysInPeriod).floor();

          // Per-period coupon payment per bond
          final double couponPaymentPerPeriod =
              faceValue * (couponRate / 100) / paymentsPerYear;

          // Last coupon payment date
          final DateTime lastCouponDate = purchaseDate
              .add(Duration(days: (periodsElapsed * daysInPeriod).floor()));

          // Days elapsed since last coupon payment
          final int daysSinceLastCoupon =
              valuationDate.difference(lastCouponDate).inDays;

          // Accrued interest per bond (only if daysSinceLastCoupon > 0)
          final double accruedInterestPerBond = daysSinceLastCoupon > 0
              ? couponPaymentPerPeriod * (daysSinceLastCoupon / daysInPeriod)
              : 0.0;

          final double totalAccruedInterest = accruedInterestPerBond * quantity;
          final double principalValue = quantity * faceValue;

          // Market value (clean price)
          final double cleanMarketValue = principalValue * (pricePct / 100.0);

          // Return dirty price if price is clean, else use market value as dirty
          return isCleanPrice
              ? cleanMarketValue + totalAccruedInterest
              : cleanMarketValue;
        }

      case InvestmentType.crypto:
        final currentPrice = parseDouble(additionalData['currentPrice']);
        return currentPrice;

      case InvestmentType.ulip:
        {
          final double units = parseDouble(additionalData['units']);
          final double nav = parseDouble(additionalData['nav']);
          final double sumAssured = parseDouble(additionalData['sumAssured']);
          final String policyStatus =
              (additionalData['policyStatus'] as String?)?.toLowerCase() ??
                  'active';

          double result;

          switch (policyStatus) {
            case 'matured':
              result = units * nav;
              break;
            case 'closed':
              result = 0.0;
              break;
            default:
              final double fundValue = units * nav;
              result = (fundValue >= sumAssured ? fundValue : sumAssured);
          }

          return result;
        }

      case InvestmentType.epf:
        {
          final double currentBalance =
              parseDouble(additionalData['currentBalance']);

          // Current EPF balance IS the current value
          return currentBalance;
        }

      case InvestmentType.other:
        {
          final currentValue = parseDouble(additionalData['currentValue']);
          return currentValue;
        }

      // ignore: unreachable_switch_default
      default:
        return amount;
    }
  }

  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Calculate gains/loss
  double getGainsLoss() {
    if (isSip) {
      final monthsInvested = DateTime.now().difference(startDate).inDays ~/ 30;
      final investedAmount = amount * monthsInvested;
      return getCurrentValue() - investedAmount;
    }
    return getCurrentValue() - amount;
  }

  double getGainsLossPercentage() {
    final invested = isSip
        ? amount * (DateTime.now().difference(startDate).inDays ~/ 30)
        : amount;
    if (invested == 0) return 0.0;
    return (getGainsLoss() / invested) * 100;
  }

  // Convert to Map for export including SIP info
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'amount': amount,
      'formattedAmount': formattedAmount,
      'startDate': startDate.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'status': status.name,
      'currentValue': getCurrentValue(),
      'gainsLoss': getGainsLoss(),
      'gainsLossPercentage': getGainsLossPercentage(),
      'additionalData': additionalData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 1)
enum InvestmentType {
  @HiveField(0)
  fixedDeposit,

  @HiveField(1)
  recurringDeposit,

  @HiveField(2)
  ppf,

  @HiveField(3)
  nps,

  @HiveField(4)
  mutualFundEquity,

  @HiveField(5)
  mutualFundDebt,

  @HiveField(6)
  mutualFundHybrid,

  @HiveField(7)
  goldETF,

  @HiveField(8)
  goldDigital,

  @HiveField(9)
  goldPhysical,

  @HiveField(10)
  realEstate,

  @HiveField(11)
  stocks,

  @HiveField(12)
  bonds,

  @HiveField(13)
  crypto,

  @HiveField(14)
  ulip,

  @HiveField(15)
  epf,

  @HiveField(16)
  other,
}

@HiveType(typeId: 2)
enum InvestmentStatus {
  @HiveField(0)
  active,

  @HiveField(1)
  matured,

  @HiveField(2)
  closed,

  @HiveField(3)
  paused,
}

extension InvestmentTypeExtension on InvestmentType {
  String get displayName {
    switch (this) {
      case InvestmentType.fixedDeposit:
        return 'Fixed Deposit (FD)';
      case InvestmentType.recurringDeposit:
        return 'Recurring Deposit (RD)';
      case InvestmentType.ppf:
        return 'Public Provident Fund (PPF)';
      case InvestmentType.nps:
        return 'National Pension Scheme (NPS)';
      case InvestmentType.mutualFundEquity:
        return 'Mutual Fund (Equity)';
      case InvestmentType.mutualFundDebt:
        return 'Mutual Fund (Debt)';
      case InvestmentType.mutualFundHybrid:
        return 'Mutual Fund (Hybrid)';
      case InvestmentType.goldETF:
        return 'Gold (ETF)';
      case InvestmentType.goldDigital:
        return 'Gold (Digital)';
      case InvestmentType.goldPhysical:
        return 'Gold (Physical)';
      case InvestmentType.realEstate:
        return 'Real Estate';
      case InvestmentType.stocks:
        return 'Stock Investments';
      case InvestmentType.bonds:
        return 'Bonds';
      case InvestmentType.crypto:
        return 'Cryptocurrency';
      case InvestmentType.ulip:
        return 'ULIP';
      case InvestmentType.epf:
        return 'EPF';
      case InvestmentType.other:
        return 'Other';
    }
  }

  String get category {
    switch (this) {
      case InvestmentType.fixedDeposit:
      case InvestmentType.recurringDeposit:
      case InvestmentType.ppf:
      case InvestmentType.bonds:
        return 'Debt';
      case InvestmentType.mutualFundEquity:
      case InvestmentType.stocks:
        return 'Equity';
      case InvestmentType.mutualFundDebt:
        return 'Debt';
      case InvestmentType.mutualFundHybrid:
        return 'Hybrid';
      case InvestmentType.goldETF:
      case InvestmentType.goldDigital:
      case InvestmentType.goldPhysical:
        return 'Gold';
      case InvestmentType.realEstate:
        return 'Real Estate';
      case InvestmentType.crypto:
        return 'Crypto';
      case InvestmentType.nps:
      case InvestmentType.epf:
      case InvestmentType.ulip:
        return 'Retirement';
      case InvestmentType.other:
        return 'Other';
    }
  }
}

extension InvestmentStatusExtension on InvestmentStatus {
  String get displayName {
    switch (this) {
      case InvestmentStatus.active:
        return 'Active';
      case InvestmentStatus.matured:
        return 'Matured';
      case InvestmentStatus.closed:
        return 'Closed';
      case InvestmentStatus.paused:
        return 'Paused';
    }
  }
}

extension InvestmentComputed on Investment {
  // Safely read maturity from additionalData or fallback to field
  DateTime? _readMaturityDate() {
    final raw = additionalData['maturityDate'];
    if (raw is DateTime) return raw; // already parsed/stored
    if (raw is String) return DateTime.tryParse(raw); // ISO-8601 string
    return maturityDate; // fallback to model field if present
  }

  // Full months between start (inclusive) and end (exclusive of partial current month)
  int _completedMonths(DateTime start, DateTime end) {
    var m = (end.year - start.year) * 12 + (end.month - start.month);
    if (end.day < start.day) m -= 1;
    return m < 0 ? 0 : m;
  }

  /// Canonical invested-to-date for all screens/providers.
  /// RD: use full tenure to maturity when a maturity date exists; SIP: cap at min(now, maturity).
  double investedToDate({DateTime? asOf}) {
    final DateTime now = asOf ?? DateTime.now();
    final DateTime? mDt = _readMaturityDate();

    // RD uses full tenure to stated maturity when available; otherwise, fall back to today.
    final bool isRD = type == InvestmentType.recurringDeposit;
    final DateTime end = isRD
        ? (mDt ?? now)
        : (mDt != null && mDt.isBefore(now) ? mDt : now);

    final bool isRecurring = isSip || isRD;
    if (isRecurring) {
      final int monthsPaid = _completedMonths(startDate, end);
      return amount * monthsPaid;
    }
    return amount; // lumpsum-style
  }
}