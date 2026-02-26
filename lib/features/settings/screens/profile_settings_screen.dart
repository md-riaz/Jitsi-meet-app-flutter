import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/services/storage_service.dart';
import 'package:alora_meet/core/services/api_client.dart';
import 'package:alora_meet/core/services/jitsi_admin_api_service.dart';
import 'package:alora_meet/shared/widgets/main_bottom_nav.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _avatarUrlController;
  late TextEditingController _apiTokenController;
  late TextEditingController _authEmailController;
  late TextEditingController _authPasswordController;
  bool _initialized = false;
  bool _authLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final settings = context.read<StorageService>().settings;
      _displayNameController = TextEditingController(text: settings.displayName);
      _emailController = TextEditingController(text: settings.email);
      _avatarUrlController =
          TextEditingController(text: settings.avatarURL ?? '');
      _apiTokenController = TextEditingController(
        text: context.read<StorageService>().apiToken ?? '',
      );
      _authEmailController = TextEditingController(text: settings.email);
      _authPasswordController = TextEditingController();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
    _apiTokenController.dispose();
    _authEmailController.dispose();
    _authPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveAll() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final storage = context.read<StorageService>();
    final avatarText = _avatarUrlController.text.trim();
    final updated = storage.settings.copyWith(
      displayName: _displayNameController.text.trim(),
      email: _emailController.text.trim(),
      avatarURL: avatarText.isEmpty ? null : avatarText,
    );
    await storage.saveSettings(updated);
    await storage.saveApiToken(_apiTokenController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  String _apiBaseFromServer(String serverUrl) {
    final root = serverUrl.endsWith('/')
        ? serverUrl.substring(0, serverUrl.length - 1)
        : serverUrl;
    return '$root/api/v1';
  }

  Future<void> _loginApiToken() async {
    final email = _authEmailController.text.trim();
    final password = _authPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required')),
      );
      return;
    }

    setState(() => _authLoading = true);
    try {
      final storage = context.read<StorageService>();
      final apiClient = ApiClient(baseUrl: _apiBaseFromServer(storage.settings.serverURL));
      final api = JitsiAdminApiService(apiClient);

      final token = await api.login(email: email, password: password);
      await storage.saveApiToken(token);
      _apiTokenController.text = token;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API login successful. Token saved.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please retry.')),
      );
    } finally {
      if (mounted) setState(() => _authLoading = false);
    }
  }

  Future<void> _logoutApiToken() async {
    final storage = context.read<StorageService>();
    await storage.saveApiToken(null);
    _apiTokenController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API token cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StorageService>().settings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      bottomNavigationBar: const MainBottomNav(currentIndex: 3),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar preview
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: theme.colorScheme.primary.withAlpha(51),
                backgroundImage: settings.avatarURL != null &&
                        settings.avatarURL!.isNotEmpty
                    ? NetworkImage(settings.avatarURL!)
                    : null,
                child: settings.avatarURL == null ||
                        settings.avatarURL!.isEmpty
                    ? Icon(Icons.person,
                        size: 48, color: theme.colorScheme.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                settings.displayName,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (settings.email.isNotEmpty)
              Center(
                child: Text(
                  settings.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Display Name
            Text('Display Name',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                hintText: 'Your display name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Display name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Email
            Text('Email',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  final emailRegex =
                      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(v.trim())) {
                    return 'Enter a valid email address';
                  }
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Avatar URL
            Text('Avatar URL',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _avatarUrlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/avatar.png (optional)',
                prefixIcon: Icon(Icons.image_outlined),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),

            Text('Jitsi Admin API Login',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _authEmailController,
              decoration: const InputDecoration(
                hintText: 'API account email',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _authPasswordController,
              decoration: const InputDecoration(
                hintText: 'API account password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _authLoading ? null : _loginApiToken,
                    icon: _authLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(_authLoading ? 'Logging in...' : 'Login & Save Token'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _logoutApiToken,
                  child: const Text('Clear'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // API Token (for /api/v1 authenticated join/list)
            Text('Jitsi Admin API Token',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _apiTokenController,
              decoration: const InputDecoration(
                hintText: 'Paste Bearer token from /api/v1/auth/login',
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
              maxLines: 2,
              minLines: 1,
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Profile'),
              onPressed: _saveAll,
            ),
          ],
        ),
      ),
    );
  }
}
