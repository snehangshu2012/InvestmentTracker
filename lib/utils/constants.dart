class AppConstants {
  // Hive Box Names
  static const String investmentBox = 'investments';
  static const String settingsBox = 'settings';
  static const String userBox = 'user';

  // Investment Types
  static const List<String> investmentTypes = [
    'Fixed Deposit (FD)',
    'Recurring Deposit (RD)',
    'Public Provident Fund (PPF)',
    'National Pension Scheme (NPS)',
    'Mutual Funds (Equity)',
    'Mutual Funds (Debt)',
    'Mutual Funds (Hybrid)',
    'Gold (ETF)',
    'Gold (Digital)',
    'Gold (Physical)',
    'Real Estate',
    'Stock Investments',
    'Bonds',
    'Cryptocurrency',
    'ULIP',
    'EPF',
    'Other',
  ];

  // Currency
  static const String currencySymbol = '₹';
  static const String currencyLocale = 'en_IN';

  // App Info
  static const String appVersion = '1.0.0';
  static const String appName = 'InvestTrack India';

  // Security
  static const String biometricReason = 'Authenticate to access your investments';
  static const String encryptionKeyName = 'investtrack_encryption_key';
}

class AppStrings {
  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalPortfolio = 'Total Portfolio Value';
  static const String todaysChange = 'Today\'s Change';
  static const String assetAllocation = 'Asset Allocation';

  // Investments
  static const String investments = 'Investments';
  static const String addInvestment = 'Add Investment';
  static const String editInvestment = 'Edit Investment';
  static const String deleteInvestment = 'Delete Investment';
  static const String investmentType = 'Investment Type';
  static const String amount = 'Amount';
  static const String startDate = 'Start Date';
  static const String maturityDate = 'Maturity Date';

  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';

  // Validation
  static const String requiredField = 'This field is required';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String invalidDate = 'Please select a valid date';
}