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
    print('AuthGate: initState called');
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('AuthGate: PostFrameCallback - setting _initDone = true');
      _initDone = true;
      _runAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('AuthGate: build called - _unlocked: $_unlocked, _authInProgress: $_authInProgress');
    
    if (_unlocked) {
      print('AuthGate: Showing child widget (app unlocked)');
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
                  print('AuthGate: Unlock button pressed');
                  // Reset flags for retry
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
    print('AuthGate: _runAuth called');
    if (_authInProgress || !_initDone) {
      print('AuthGate: Skipping auth - authInProgress: $_authInProgress, initDone: $_initDone');
      return;
    }

    setState(() => _authInProgress = true);
    print('AuthGate: Starting authentication process');

    final s = ref.read(settingsProvider);
    print('AuthGate: Settings - biometric: ${s.biometricEnabled}, pin: ${s.pinEnabled}');

    try {
      // If no security enabled, unlock immediately
      if (!s.biometricEnabled && !s.pinEnabled) {
        print('AuthGate: No security enabled, unlocking immediately');
        _unlock();
        return;
      }

      // Try biometric once per launch
      if (s.biometricEnabled && !_biometricTried) {
        print('AuthGate: Attempting biometric authentication');
        _biometricTried = true;
        _biometricInFlight = true;
        
        final ok = await BiometricHelper.authenticate(
          localizedReason: 'Authenticate to access your investments',
          biometricOnly: false,
        );
        
        _biometricInFlight = false;
        print('AuthGate: Biometric result: $ok');
        
        if (ok) {
          print('AuthGate: Biometric successful, unlocking');
          _unlock();
          return;
        }
      }

      // Try PIN
      if (s.pinEnabled) {
        print('AuthGate: Attempting PIN authentication');
        final ok = await _showPinDialog(s.userPin);
        print('AuthGate: PIN authentication result: $ok');
        
        if (ok) {
          print('AuthGate: PIN successful, unlocking');
          _unlock();
          return;
        }
      }

      // Neither succeeded
      print('AuthGate: Authentication failed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Tap Unlock to try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('AuthGate: Error during authentication: $e');
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
      print('AuthGate: Auth process finished, _authInProgress = false');
    }
  }

void _unlock() {
    print('AuthGate: _unlock() called - setting _unlocked = true');
    if (mounted) {
      setState(() {
        _unlocked = true;
        _justAuthenticated = true; // Set flag when we unlock
      });
      print('AuthGate: State updated, _unlocked = $_unlocked');
      
      // Reset the flag after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        _justAuthenticated = false;
      });
    } else {
      print('AuthGate: Widget not mounted, cannot setState');
    }
  }

  Future<bool> _showPinDialog(String? saved) async {
    print('AuthGate: Showing PIN dialog, expected PIN: $saved');
    
    if (!mounted) {
      print('AuthGate: Not mounted, cannot show dialog');
      return false;
    }

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
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('AuthGate: PIN dialog cancelled');
              Navigator.pop(context, null);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              print('AuthGate: PIN dialog submitted with: ${ctrl.text}');
              Navigator.pop(context, ctrl.text);
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );

    print('AuthGate: PIN dialog returned: $input');

    if (input == null) {
      print('AuthGate: PIN dialog was cancelled');
      return false;
    }

    if (input == saved) {
      print('AuthGate: PIN is correct');
      return true;
    } else {
      print('AuthGate: PIN is incorrect - entered: "$input", expected: "$saved"');
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Incorrect PIN'),
            content: Text('Wrong PIN. Entered: "$input", Expected: "$saved"'), // Debug info
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AuthGate: App lifecycle changed to: $state');
    
    if (_biometricInFlight) {
      print('AuthGate: Biometric in flight, ignoring lifecycle change');
      return;
    }
    
    // Don't re-lock if we just authenticated
    if (_justAuthenticated) {
      print('AuthGate: Just authenticated, ignoring resume');
      return;
    }
    
    if (state == AppLifecycleState.resumed && _unlocked) {
      final s = ref.read(settingsProvider);
      if (s.biometricEnabled || s.pinEnabled) {
        print('AuthGate: App resumed, re-locking');
        setState(() => _unlocked = false);
      }
    }
  }

  @override
  void dispose() {
    print('AuthGate: dispose called');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
