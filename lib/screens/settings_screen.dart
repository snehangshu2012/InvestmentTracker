import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';
import '../utils/biometric_helper.dart';
import 'package:local_auth/local_auth.dart';
import '../models/settings_model.dart';
import '../utils/export_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsProvider);
      _nameController.text = settings.userName;
      _emailController.text = settings.userEmail;
    });
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(settings),
            const SizedBox(height: 24),
            _buildAppPreferencesSection(settings),
            const SizedBox(height: 24),
            _buildSecuritySection(settings),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(AppSettings settings) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Profile & Account',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  settings.userName.isNotEmpty
                      ? settings.userName[0].toUpperCase()
                      : 'U',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateUserInfo(value, _emailController.text);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateUserInfo(_nameController.text, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppPreferencesSection(AppSettings settings) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('App Preferences',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: const Text('Use dark mode interface'),
            value: settings.isDarkTheme,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).updateDarkTheme(value);
            },
            secondary:
                Icon(settings.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
          ),
        ]),
      ),
    );
  }

  Widget _buildSecuritySection(AppSettings settings) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('Security & Privacy',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),

          // Biometric Toggle
          // Biometric Toggle (no automatic disabling)
          FutureBuilder<List<BiometricType>>(
            future: BiometricHelper.getAvailableBiometrics(),
            builder: (context, snap) {
              final types = snap.data ?? [];
              final isAvailable = types.isNotEmpty;
              final label = isAvailable
                  ? BiometricHelper.getBiometricTypeString(types)
                  : 'Biometric not available';

              return SwitchListTile(
                title: Text('Use $label'),
                subtitle: Text(isAvailable
                    ? 'Unlock with $label'
                    : 'No biometric sensor detected'),
                value: settings.biometricEnabled && isAvailable,
                onChanged: isAvailable
                    ? (on) async {
                        if (on) {
                          // Disable PIN if active
                          if (settings.pinEnabled) {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Disable PIN?'),
                                content: const Text(
                                    'Enabling biometrics will disable PIN lock. Continue?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('OK')),
                                ],
                              ),
                            );
                            if (ok != true) return;
                            await ref
                                .read(settingsProvider.notifier)
                                .updatePin(false, null);
                          }
                          // Enforce biometric-only auth here
                          final enrolled = await BiometricHelper.authenticate(
                            localizedReason: 'Confirm to enable $label',
                            biometricOnly: true,
                          );
                          if (enrolled) {
                            await ref
                                .read(settingsProvider.notifier)
                                .updateBiometric(true);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('$label enabled'),
                                    backgroundColor: Colors.green),
                              );
                            }
                          }
                        } else {
                          await ref
                              .read(settingsProvider.notifier)
                              .updateBiometric(false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Biometric disabled'),
                                  backgroundColor: Colors.blue),
                            );
                          }
                        }
                      }
                    : null,
                secondary: Icon(Icons.fingerprint,
                    color: isAvailable ? null : Colors.grey),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('PIN Lock'),
            subtitle: const Text('Use a 4-digit PIN'),
            value: settings.pinEnabled,
            onChanged: (on) async {
              if (on) {
                // If biometric was on, confirm disabling it
                if (settings.biometricEnabled) {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Disable Biometric?'),
                      content: const Text(
                          'Enabling PIN will disable biometrics. Continue?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true) return;
                  await ref
                      .read(settingsProvider.notifier)
                      .updateBiometric(false);
                }
                // Show PIN setup dialog
                _showPinSetupDialog();
              } else {
                await ref.read(settingsProvider.notifier).updatePin(false);
              }
            },
            secondary: const Icon(Icons.pin),
          ),
          const Divider(),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Download your investment data'),
            leading: const Icon(Icons.download),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _exportData,
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear All Data'),
            subtitle:
                const Text('Remove all investments and settings permanently'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showClearDataDialog,
          ),
        ]),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text('About & Support',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Version'),
            subtitle: Text(_packageInfo?.version ?? 'Loading...'),
            leading: const Icon(Icons.info_outline),
          ),
          const Divider(),
          ListTile(
            title: const Text('Help & Support'),
            subtitle: const Text('Get help using the app'),
            leading: const Icon(Icons.help_outline),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showHelpDialog,
          ),
          const Divider(),
          ListTile(
            title: const Text('Send Feedback'),
            subtitle: const Text('Help us improve the app'),
            leading: const Icon(Icons.feedback_outlined),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showFeedbackDialog,
          ),
        ]),
      ),
    );
  }

  void _showPinSetupDialog() {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: pinController,
            decoration: const InputDecoration(
              labelText: 'Enter PIN',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: confirmPinController,
            decoration: const InputDecoration(
              labelText: 'Confirm PIN',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (pinController.text == confirmPinController.text &&
                  pinController.text.length == 4) {
                ref
                    .read(settingsProvider.notifier)
                    .updatePin(true, pinController.text);
                Navigator.pop(context);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN set successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PINs do not match or invalid length'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Set PIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final exportMap = ref.read(localDbServiceProvider).exportAllData();
      final investments =
          (exportMap['investments'] as List).cast<Map<String, dynamic>>();
      await ExportHelper.exportInvestmentsCsv(investments);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'This will permanently delete all your investments and settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                final dbService = ref.read(localDbServiceProvider);
                await dbService.clearAllData();
                ref.invalidate(settingsProvider);
                Navigator.pop(context);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error clearing data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How to use Investment Tracker:'),
              SizedBox(height: 8),
              Text('• Add investments with +'),
              Text('• View performance in Analytics'),
              Text('• Track gains/losses in real-time'),
              Text('• Configure security in Settings'),
              SizedBox(height: 16),
              Text('Contact: support@investmenttracker.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: 'Your feedback…',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final feedback = feedbackController.text.trim();
              if (feedback.isEmpty) {
                // Prevent empty feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter some feedback before sending.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              final subject = Uri.encodeComponent('InvestTrack Feedback');
              final body = Uri.encodeComponent(feedback);
              final mailto = 'mailto:support@investmenttracker.com'
                  '?subject=$subject&body=$body';

              if (await canLaunchUrl(Uri.parse(mailto))) {
                await launchUrl(Uri.parse(mailto));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not open email client.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
