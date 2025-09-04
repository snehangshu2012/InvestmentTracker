import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import 'dart:convert';

class SettingsService {
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();
  SettingsService._();

  static const String _settingsKey = 'app_settings';

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson != null) {
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return AppSettings.fromMap(settingsMap);
    }
    
    return AppSettings(); // Return default settings
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(settings.toMap());
    await prefs.setString(_settingsKey, settingsJson);
  }

  Future<void> updateSetting<T>(String key, T value) async {
    final currentSettings = await getSettings();
    late AppSettings updatedSettings;

    switch (key) {
      case 'isDarkTheme':
        updatedSettings = currentSettings.copyWith(isDarkTheme: value as bool);
        break;
      case 'biometricEnabled':
        updatedSettings = currentSettings.copyWith(biometricEnabled: value as bool);
        break;
      case 'pinEnabled':
        updatedSettings = currentSettings.copyWith(pinEnabled: value as bool);
        break;
      case 'userPin':
        updatedSettings = currentSettings.copyWith(userPin: value as String?);
        break;
      case 'userName':
        updatedSettings = currentSettings.copyWith(userName: value as String);
        break;
      case 'userEmail':
        updatedSettings = currentSettings.copyWith(userEmail: value as String);
        break;
      case 'notificationsEnabled':
        updatedSettings = currentSettings.copyWith(notificationsEnabled: value as bool);
        break;
      case 'defaultCurrency':
        updatedSettings = currentSettings.copyWith(defaultCurrency: value as String);
        break;
      case 'compactView':
        updatedSettings = currentSettings.copyWith(compactView: value as bool);
        break;
      default:
        return; // Invalid key, don't save
    }

    await saveSettings(updatedSettings);
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }
}
