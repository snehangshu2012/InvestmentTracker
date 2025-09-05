// screens/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../utils/biometric_helper.dart';

class AuthGate extends ConsumerStatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _authInProgress = false;
  bool _initDone = false;
  bool _biometricTried = false;
  bool _biometricInFlight = false;
  bool _justAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDone = true;
      _runAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) {
      return widget.child;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_authInProgress) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Authenticating...'),
            ] else ...[
              const Icon(Icons.lock, size: 64, color: Colors.grey),
              const SizedBox(height: 20),
              const Text('App is locked'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _biometricTried = false;
                  _runAuth();
                },
                child: const Text('Unlock'),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _runAuth() async {
    if (_authInProgress || !_initDone) return;
    setState(() => _authInProgress = true);

    final settings = ref.read(settingsProvider);

    try {
      // No security enabled
      if (!settings.biometricEnabled && !settings.pinEnabled) {
        _unlock();
        return;
      }

      // Biometric once per launch
      if (settings.biometricEnabled && !_biometricTried) {
        _biometricTried = true;
        _biometricInFlight = true;

        final ok = await BiometricHelper.authenticate(
          localizedReason: 'Authenticate to access your investments',
          biometricOnly: true,
        );

        _biometricInFlight = false;

        if (ok) {
          _unlock();
          return;
        }
      }

      // PIN fallback
      if (settings.pinEnabled) {
        final ok = await _showPinDialog(settings.userPin);
        if (ok) {
          _unlock();
          return;
        }
      }

      // Authentication failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Tap Unlock to try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _authInProgress = false);
    }
  }

  void _unlock() {
    if (!mounted) return;
    setState(() {
      _unlocked = true;
      _justAuthenticated = true;
    });
    // Prevent immediate relock
    Future.delayed(const Duration(seconds: 2), () {
      _justAuthenticated = false;
    });
  }

  Future<bool> _showPinDialog(String? savedPin) async {
    if (!mounted) return false;

    final controller = TextEditingController();
    final input = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );

    if (input == null) return false;
    if (input == savedPin) return true;

    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Incorrect PIN'),
          content: const Text('Wrong PIN. Please try again.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_biometricInFlight) return;
    if (_justAuthenticated) return;

    if (state == AppLifecycleState.resumed && _unlocked) {
      final settings = ref.read(settingsProvider);
      if (settings.biometricEnabled || settings.pinEnabled) {
        setState(() => _unlocked = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
