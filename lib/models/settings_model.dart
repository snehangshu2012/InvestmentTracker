import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkTheme;

  @HiveField(1)
  bool biometricEnabled;

  @HiveField(2)
  bool pinEnabled;

  @HiveField(3)
  String? userPin;

  @HiveField(4)
  String userName;

  @HiveField(5)
  String userEmail;

  @HiveField(6)
  bool notificationsEnabled;

  @HiveField(7)
  String defaultCurrency;

  @HiveField(8)
  bool compactView;

  AppSettings({
    this.isDarkTheme = false,
    this.biometricEnabled = false,
    this.pinEnabled = false,
    this.userPin,
    this.userName = '',
    this.userEmail = '',
    this.notificationsEnabled = true,
    this.defaultCurrency = 'INR',
    this.compactView = false,
  });

  AppSettings copyWith({
    bool? isDarkTheme,
    bool? biometricEnabled,
    bool? pinEnabled,
    String? userPin,
    String? userName,
    String? userEmail,
    bool? notificationsEnabled,
    String? defaultCurrency,
    bool? compactView,
  }) {
    return AppSettings(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      userPin: userPin ?? this.userPin,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      compactView: compactView ?? this.compactView,
    );
  }

  // Add the missing toMap method
  Map<String, dynamic> toMap() {
    return {
      'isDarkTheme': isDarkTheme,
      'biometricEnabled': biometricEnabled,
      'pinEnabled': pinEnabled,
      'userPin': userPin,
      'userName': userName,
      'userEmail': userEmail,
      'notificationsEnabled': notificationsEnabled,
      'defaultCurrency': defaultCurrency,
      'compactView': compactView,
    };
  }

  // Add the missing fromMap factory constructor
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      isDarkTheme: map['isDarkTheme'] ?? false,
      biometricEnabled: map['biometricEnabled'] ?? false,
      pinEnabled: map['pinEnabled'] ?? false,
      userPin: map['userPin'],
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      defaultCurrency: map['defaultCurrency'] ?? 'INR',
      compactView: map['compactView'] ?? false,
    );
  }
}

enum TimePeriod {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  all,
}

extension TimePeriodExtension on TimePeriod {
  String get displayName {
    switch (this) {
      case TimePeriod.oneMonth:
        return '1M';
      case TimePeriod.threeMonths:
        return '3M';
      case TimePeriod.sixMonths:
        return '6M';
      case TimePeriod.oneYear:
        return '1Y';
      case TimePeriod.all:
        return 'All';
    }
  }

  int get months {
    switch (this) {
      case TimePeriod.oneMonth:
        return 1;
      case TimePeriod.threeMonths:
        return 3;
      case TimePeriod.sixMonths:
        return 6;
      case TimePeriod.oneYear:
        return 12;
      case TimePeriod.all:
        return 0; // 0 means all time
    }
  }
}
