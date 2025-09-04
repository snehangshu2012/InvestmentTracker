import 'package:intl/intl.dart';
import 'dart:math';

class CurrencyHelper {
  // Formats a double as Indian Rupees currency with no decimals, e.g., ₹1,23,456
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Formats a double as Indian Rupees with 2 decimal places, e.g., ₹1,23,456.78
  static String formatCurrencyWithDecimals(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Formats a DateTime object into 'dd MMM yyyy' format, e.g., '24 Aug 2025'
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Converts large numbers into compact form, e.g., 1500000 -> 1.5M
  static String formatCompact(double amount) {
    if (amount >= 1e7) {
      return '₹${(amount / 1e7).toStringAsFixed(1)}Cr';
    } else if (amount >= 1e5) {
      return '₹${(amount / 1e5).toStringAsFixed(1)}L';
    } else if (amount >= 1e3) {
      return '₹${(amount / 1e3).toStringAsFixed(1)}K';
    } else {
      return formatCurrencyWithDecimals(amount);
    }
  }

  // Pad numbers with commas for Indian numbering system, e.g., 1234567 -> 12,34,567
  static String formatINR(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static final NumberFormat _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  //static final NumberFormat _compactIndianFormat = NumberFormat.compactCurrency(
  //locale: 'en_IN',
  //symbol: '₹',
  //decimalDigits: 1,
  //);

  /// Format amount in Indian Rupees (e.g., ₹1,00,000.00)
  static String formatAmount(double amount) {
    return _indianFormat.format(amount);
  }

  /// Format large amounts in compact form (e.g., ₹1.5L, ₹2.3Cr)
  /// Format large amounts in compact form (e.g., ₹1.5L, ₹2.3Cr)
  static String formatCompactAmount(double amount) {
    if (amount >= 10000000) {
      // 1 crore
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      // 1 lakh
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      // 1 thousand
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return formatAmount(amount);
  }

  /// Parse Indian formatted currency string to double
  static double parseAmount(String formattedAmount) {
    String cleaned = formattedAmount.replaceAll(RegExp(r'[₹,\s]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}

class DateHelper {
  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  static String formatDisplayDate(DateTime date) {
    return _displayFormat.format(date);
  }

  static String formatApiDate(DateTime date) {
    return _apiFormat.format(date);
  }

  static DateTime? parseApiDate(String dateString) {
    try {
      return _apiFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static double yearsBetween(DateTime from, DateTime to) {
    return daysBetween(from, to) / 365.25;
  }
}

class CalculationHelper {
  /// Calculate Simple Interest
  static double calculateSimpleInterest({
    required double principal,
    required double rate,
    required double timeInYears,
  }) {
    return (principal * rate * timeInYears) / 100;
  }

  /// Calculate Compound Interest
  static double calculateCompoundInterest({
    required double principal,
    required double rate,
    required int compoundingFrequency,
    required double timeInYears,
  }) {
    return principal *
            pow(1 + rate / (100 * compoundingFrequency),
                compoundingFrequency * timeInYears) -
        principal;
  }

  /// Calculate SIP maturity amount
  static double calculateSIPMaturityAmount({
    required double monthlyAmount,
    required double annualRate,
    required int totalMonths,
  }) {
    double monthlyRate = annualRate / (12 * 100);
    return monthlyAmount *
        ((pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate) *
        (1 + monthlyRate);
  }

  /// Calculate CAGR (Compound Annual Growth Rate)
  static double calculateCAGR({
    required double initialValue,
    required double finalValue,
    required double years,
  }) {
    if (initialValue <= 0 || finalValue <= 0 || years <= 0) return 0.0;
    return (pow(finalValue / initialValue, 1 / years) - 1) * 100;
  }

  /// Calculate percentage change
  static double calculatePercentageChange({
    required double initialValue,
    required double currentValue,
  }) {
    if (initialValue == 0) return 0.0;
    return ((currentValue - initialValue) / initialValue) * 100;
  }

  /// Calculate maturity amount for Fixed Deposit
  static double calculateFDMaturityAmount({
    required double principal,
    required double annualRate,
    required int compoundingFrequency,
    required double years,
  }) {
    return principal *
        pow(1 + (annualRate / 100) / compoundingFrequency,
            compoundingFrequency * years);
  }
}

class ValidationHelper {
  static bool isValidAmount(String amount) {
    if (amount.isEmpty) return false;
    final double? value = double.tryParse(amount);
    return value != null && value > 0;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^[6-9]\d{9}\$').hasMatch(phone);
  }

  static bool isValidPAN(String pan) {
    return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}\$').hasMatch(pan);
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '\$fieldName is required';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    if (!isValidAmount(value)) {
      return 'Please enter a valid amount';
    }
    return null;
  }
}

int compoundingFreqToInt(String freq) {
  switch (freq.toLowerCase()) {
    case 'annually':
      return 1;
    case 'half-yearly':
      return 2;
    case 'quarterly':
      return 4;
    case 'monthly':
      return 12;
    default:
      return 4;
  }
}