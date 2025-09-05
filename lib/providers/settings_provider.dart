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
      if (loaded == null) {
        // First run: persist defaults
        await _dbService.saveAppSettings(state);
      } else {
        state = loaded;

        // Migration: if PIN is off but a PIN value exists, scrub it
        if (!state.pinEnabled && (state.userPin?.isNotEmpty ?? false)) {
          await _saveSettings(state.copyWith(userPin: null));
        }

        // Migration: if biometrics are on while PIN is still set, ensure mutual exclusivity
        if (state.biometricEnabled && (state.pinEnabled || (state.userPin?.isNotEmpty ?? false))) {
          await _saveSettings(state.copyWith(pinEnabled: false, userPin: null));
        }
      }
    } catch (_) {}
  }

  Future<void> _saveSettings(AppSettings s) async {
    try {
      if (!_dbService.isInitialized) await _dbService.init();
      await _dbService.saveAppSettings(s);
      state = s;
    } catch (_) {}
  }

  // Enable/disable PIN.
  // When disabling, always clear userPin to avoid lingering sensitive data.
  Future<void> updatePin(bool enabled, [String? pin]) async {
    final sanitizedPin = enabled ? pin : null;
    await _saveSettings(
      state.copyWith(pinEnabled: enabled, userPin: sanitizedPin),
    );
  }

  // Enable/disable biometrics.
  // When enabling biometrics, enforce mutual exclusivity by disabling PIN and clearing userPin.
  Future<void> updateBiometric(bool enabled) async {
    if (enabled) {
      await _saveSettings(
        state.copyWith(
          biometricEnabled: true,
          pinEnabled: false,
          userPin: null,
        ),
      );
    } else {
      await _saveSettings(state.copyWith(biometricEnabled: false));
    }
  }

  Future<void> updateDarkTheme(bool v) async =>
      _saveSettings(state.copyWith(isDarkTheme: v));

  Future<void> updateCompactView(bool v) async =>
      _saveSettings(state.copyWith(compactView: v));

  Future<void> updateUserInfo(String name, String email) async =>
      _saveSettings(state.copyWith(userName: name, userEmail: email));

  Future<void> updateNotifications(bool v) async =>
      _saveSettings(state.copyWith(notificationsEnabled: v));

  Future<void> updateCurrency(String c) async =>
      _saveSettings(state.copyWith(defaultCurrency: c));

  Future<void> resetToDefaults() async => _saveSettings(AppSettings());
}
