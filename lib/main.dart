// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/investment_model.dart';
import 'models/settings_model.dart';
import 'providers/settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters once
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(InvestmentAdapter());
    Hive.registerAdapter(InvestmentTypeAdapter());
    Hive.registerAdapter(InvestmentStatusAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
  }

  // Open typed boxes
  await Hive.openBox<Investment>('investments');
  await Hive.openBox<AppSettings>('settings');

  runApp(const ProviderScope(child: InvestTrackApp()));
}

class InvestTrackApp extends ConsumerWidget {
  const InvestTrackApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider); // loaded from Hive

    return MaterialApp(
      title: 'InvestTrack India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2), brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2), brightness: Brightness.dark),
        useMaterial3: true,
      ),
      // Bind theme mode to user setting
      themeMode: settings.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      // Gate app if biometric/pin enabled
      home: const AuthGate(child: DashboardScreen()),
    );
  }
}
