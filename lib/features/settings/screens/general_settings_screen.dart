import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/services/storage_service.dart';

class GeneralSettingsScreen extends StatefulWidget {
  const GeneralSettingsScreen({super.key});

  @override
  State<GeneralSettingsScreen> createState() => _GeneralSettingsScreenState();
}

class _GeneralSettingsScreenState extends State<GeneralSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serverUrlController;
  bool _initialized = false;

  static const _languages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ar': 'العربية',
    'hi': 'हिन्दी',
    'ru': 'Русский',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final settings = context.read<StorageService>().settings;
      _serverUrlController = TextEditingController(text: settings.serverURL);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context,
      {String? serverURL, String? language, bool? darkMode}) async {
    final storage = context.read<StorageService>();
    final updated = storage.settings.copyWith(
      serverURL: serverURL,
      language: language,
      darkMode: darkMode,
    );
    await storage.saveSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StorageService>().settings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('General')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Server URL
            Text('Server URL',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            TextFormField(
              controller: _serverUrlController,
              decoration: const InputDecoration(
                hintText: 'https://app.alorameet.com',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Server URL is required';
                }
                final uri = Uri.tryParse(v.trim());
                if (uri == null ||
                    !uri.isAbsolute ||
                    (!uri.scheme.startsWith('http'))) {
                  return 'Enter a valid URL (e.g. https://app.alorameet.com)';
                }
                return null;
              },
              onFieldSubmitted: (v) {
                if (_formKey.currentState?.validate() ?? false) {
                  _save(context, serverURL: v.trim());
                }
              },
              onEditingComplete: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _save(context, serverURL: _serverUrlController.text.trim());
                }
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _save(context,
                        serverURL: _serverUrlController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Server URL saved')),
                    );
                  }
                },
                child: const Text('Save URL'),
              ),
            ),

            const Divider(height: 32),

            // Language
            Text('Language',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: settings.language,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.language),
              ),
              items: _languages.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) _save(context, language: v);
              },
            ),

            const Divider(height: 32),

            // Theme
            SwitchListTile(
              title: Text('Dark Mode',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(
                settings.darkMode ? 'Dark theme active' : 'Light theme active',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
              secondary: Icon(
                settings.darkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              value: settings.darkMode,
              onChanged: (v) => _save(context, darkMode: v),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
