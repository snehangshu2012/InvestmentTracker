import 'package:hive_flutter/hive_flutter.dart';
import '../models/investment_model.dart';
import '../models/settings_model.dart';

class LocalDbService {
  static LocalDbService? _instance;
  static LocalDbService get instance => _instance ??= LocalDbService._();
  LocalDbService._();

  late Box<Investment> _investmentBox;
  late Box<AppSettings> _settingsBox;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  // Fetch references only; boxes are already opened (and typed) in main.dart
  Future<void> init() async {
    if (_initialized) return;
    _investmentBox = Hive.box<Investment>('investments');
    _settingsBox   = Hive.box<AppSettings>('settings');
    _initialized = true;
  }

  // Investment CRUD
  Future<void> addInvestment(Investment investment) async {
    if (!_initialized) await init();
    await _investmentBox.put(investment.id, investment);
  }

  List<Investment> getAllInvestments() {
    if (!_initialized) return [];
    return _investmentBox.values.toList();
  }

  Investment? getInvestmentById(String id) {
    if (!_initialized) return null;
    return _investmentBox.get(id);
  }

  Future<void> updateInvestment(Investment investment) async {
    if (!_initialized) await init();
    investment.updatedAt = DateTime.now();
    await _investmentBox.put(investment.id, investment);
  }

  Future<void> deleteInvestment(String id) async {
    if (!_initialized) await init();
    await _investmentBox.delete(id);
  }

  List<Investment> getInvestmentsByType(InvestmentType type) {
    if (!_initialized) return [];
    return _investmentBox.values.where((inv) => inv.type == type).toList();
  }

  List<Investment> getInvestmentsByStatus(InvestmentStatus status) {
    if (!_initialized) return [];
    return _investmentBox.values.where((inv) => inv.status == status).toList();
  }

  List<Investment> getInvestmentsByDateRange(DateTime start, DateTime end) {
    if (!_initialized) return [];
    return _investmentBox.values
      .where((inv) => inv.startDate.isAfter(start) && inv.startDate.isBefore(end))
      .toList();
  }

  List<Investment> searchInvestments(String query) {
    if (!_initialized) return [];
    final q = query.toLowerCase();
    return _investmentBox.values
      .where((inv) => inv.name.toLowerCase().contains(q))
      .toList();
  }

  // Portfolio
  double getTotalPortfolioValue() {
    if (!_initialized) return 0.0;
    return _investmentBox.values.fold(0.0, (s, inv) => s + inv.getCurrentValue());
  }

  double getTotalInvestedAmount() {
    if (!_initialized) return 0.0;
    return _investmentBox.values.fold(0.0, (s, inv) => s + inv.amount);
  }

  double getTotalGainsLoss() => getTotalPortfolioValue() - getTotalInvestedAmount();

  Map<String, double> getPortfolioAllocation() {
    if (!_initialized) return {};
    final total = getTotalPortfolioValue();
    if (total == 0) return {};
    final alloc = <String, double>{};
    for (final inv in _investmentBox.values) {
      alloc[inv.type.category] = (alloc[inv.type.category] ?? 0.0) + inv.getCurrentValue();
    }
    alloc.updateAll((k, v) => v / total * 100);
    return alloc;
  }

  Map<InvestmentType, int> getInvestmentCountByType() {
    if (!_initialized) return {};
    final counts = <InvestmentType, int>{};
    for (final inv in _investmentBox.values) {
      counts[inv.type] = (counts[inv.type] ?? 0) + 1;
    }
    return counts;
  }

  // Settings
  Future<void> saveAppSettings(AppSettings settings) async {
    if (!_initialized) await init();
    await _settingsBox.put('app_settings', settings);
  }

  AppSettings? getAppSettings() {
    if (!_initialized) return null;
    return _settingsBox.get('app_settings');
  }

  Future<void> deleteSetting(String key) async {
    if (!_initialized) await init();
    await _settingsBox.delete(key);
  }

  // Data management
  Map<String, dynamic> exportAllData() {
    if (!_initialized) return {};
    return {
      'investments': _investmentBox.values.map((inv) => inv.toMap()).toList(),
      'settings': getAppSettings()?.toMap() ?? {},
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  Future<void> clearAllData() async {
    if (!_initialized) await init();
    await _investmentBox.clear();
    await _settingsBox.clear();
  }

  Future<void> close() async {
    await _investmentBox.close();
    await _settingsBox.close();
    _initialized = false;
  }
}
