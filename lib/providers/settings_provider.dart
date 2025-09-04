// settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../services/local_db_service.dart';

final localDbServiceProvider = Provider<LocalDbService>((ref) {
  return LocalDbService.instance;
});

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(localDbServiceProvider));
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final LocalDbService _dbService;
  SettingsNotifier(this._dbService) : super(AppSettings()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _dbService.init();
      await _loadSettings();
    } catch (_) {}
  }

  Future<void> _loadSettings() async {
    try {
      final loaded = _dbService.getAppSettings();
      // Persist a default once so subsequent boots don’t see “null” and unlock
      if (loaded == null) {
        await _dbService.saveAppSettings(state);
      } else {
        state = loaded;
      }
    } catch (_) {}
  }

  Future<void> _saveSettings(AppSettings settings) async {
    try {
      if (!_dbService.isInitialized) {
        await _dbService.init();
      }
      await _dbService.saveAppSettings(settings);
      state = settings;
    } catch (_) {}
  }

  Future<void> updateDarkTheme(bool isDark) async =>
      _saveSettings(state.copyWith(isDarkTheme: isDark));

  Future<void> updateCompactView(bool compact) async =>
      _saveSettings(state.copyWith(compactView: compact));

  Future<void> updateBiometric(bool enabled) async =>
      _saveSettings(state.copyWith(biometricEnabled: enabled));

  Future<void> updatePin(bool enabled, [String? pin]) async =>
      _saveSettings(state.copyWith(pinEnabled: enabled, userPin: pin));

  Future<void> updateUserInfo(String name, String email) async =>
      _saveSettings(state.copyWith(userName: name, userEmail: email));

  Future<void> updateNotifications(bool enabled) async =>
      _saveSettings(state.copyWith(notificationsEnabled: enabled));

  Future<void> updateCurrency(String currency) async =>
      _saveSettings(state.copyWith(defaultCurrency: currency));

  Future<void> resetToDefaults() async => _saveSettings(AppSettings());
}
