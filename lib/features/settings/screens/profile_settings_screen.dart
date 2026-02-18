import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/services/storage_service.dart';

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
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final settings = context.read<StorageService>().settings;
      _displayNameController = TextEditingController(text: settings.displayName);
      _emailController = TextEditingController(text: settings.email);
      _avatarUrlController =
          TextEditingController(text: settings.avatarURL ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose();
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StorageService>().settings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
