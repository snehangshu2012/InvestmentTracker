// screens/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:investtrack_india/models/settings_model.dart';
import '../providers/settings_provider.dart';
import '../utils/biometric_helper.dart';

class AuthGate extends ConsumerStatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});
  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

// screens/auth_gate.dart

// screens/auth_gate.dart

class _AuthGateState extends ConsumerState<AuthGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _authInProgress = false;
  bool _initDone = false;

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
    if (_unlocked) return widget.child;

    return Scaffold(
      body: Center(
        child: _authInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _runAuth,
                child: const Text('Unlock'),
              ),
      ),
    );
  }

Future<void> _runAuth() async {
  if (_authInProgress || !_initDone) return;
  _authInProgress = true;
  setState(() {});

  final s = ref.read(settingsProvider);
  try {
    // 1. Biometric once
    if (s.biometricEnabled) {
      final ok = await BiometricHelper.authenticate(
        localizedReason: 'Authenticate to access your investments',
        biometricOnly: false, // system prompt + fallback
      );
      if (ok) {
        _unlock();
        return;
      }
    }

    // 2. PIN once
    if (s.pinEnabled) {
      final ok = await _showPinDialog(s.userPin);
      if (ok) {
        _unlock();
        return;
      }
    }

    // 3. Neither succeeded: remain locked but do NOT loop back
    // Show a message so user can manually retry
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication failed. Tap Unlock to try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    // On unexpected error, remain locked but show error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during authentication: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    _authInProgress = false;
    setState(() {});
  }
}

  void _unlock() {
    setState(() {
      _unlocked = true;
    });
  }

  Future<bool> _showPinDialog(String? saved) async {
    final ctrl = TextEditingController();
    final input = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Enter PIN'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Unlock')),
        ],
      ),
    );
    if (input == null) return false;
    if (input == saved) return true;

    // Wrong PIN
    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Incorrect PIN'),
          content: const Text('Wrong PIN, please try again.'),
          actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Retry'))],
        ),
      );
    }
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _unlocked) {
      final s = ref.read(settingsProvider);
      if (s.biometricEnabled || s.pinEnabled) {
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
