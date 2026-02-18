import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/services/storage_service.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  late TextEditingController _jsonController;
  String? _jsonError;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final overrides = context.read<StorageService>().settings.configOverrides;
      _jsonController = TextEditingController(
        text: _prettyJson(overrides),
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  String _prettyJson(Map<String, dynamic> map) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }

  Future<void> _parseAndSave() async {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      final storage = context.read<StorageService>();
      await storage.saveSettings(
          storage.settings.copyWith(configOverrides: {}));
      setState(() => _jsonError = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Config overrides cleared')),
        );
      }
      return;
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        setState(() => _jsonError = 'JSON must be an object (not array)');
        return;
      }
      final storage = context.read<StorageService>();
      await storage.saveSettings(
          storage.settings.copyWith(configOverrides: decoded));
      setState(() => _jsonError = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Config overrides saved')),
        );
      }
    } on FormatException catch (e) {
      setState(() => _jsonError = 'Invalid JSON: ${e.message}');
    }
  }

  Future<void> _exportToClipboard() async {
    final overrides = context.read<StorageService>().settings.configOverrides;
    await Clipboard.setData(ClipboardData(text: _prettyJson(overrides)));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  Future<void> _importFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _jsonController.text = data.text!;
      setState(() => _jsonError = null);
    }
  }

  Future<void> _resetOverrides() async {
    final storage = context.read<StorageService>();
    await storage
        .saveSettings(storage.settings.copyWith(configOverrides: {}));
    _jsonController.text = _prettyJson({});
    setState(() => _jsonError = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Config overrides reset')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StorageService>().settings;
    final theme = Theme.of(context);
    final enabledFlags =
        settings.featureFlags.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // JSON Editor
          Text('Config Overrides',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 4),
          Text(
            'Add custom Jitsi configuration as JSON',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _jsonController,
            maxLines: 12,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: '{\n  "key": "value"\n}',
              hintStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              errorText: _jsonError,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Parse & Save'),
                onPressed: _parseAndSave,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.content_paste, size: 18),
                label: const Text('Import'),
                onPressed: _importFromClipboard,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Export'),
                onPressed: _exportToClipboard,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                onPressed: _resetOverrides,
              ),
            ],
          ),

          const Divider(height: 40),

          // Diagnostics
          Text('Diagnostics',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DiagnosticRow(
                    label: 'Server URL',
                    value: settings.serverURL,
                    icon: Icons.dns_outlined,
                  ),
                  const Divider(height: 20),
                  _DiagnosticRow(
                    label: 'Total Flags',
                    value: '${settings.featureFlags.length}',
                    icon: Icons.flag_outlined,
                  ),
                  const Divider(height: 20),
                  _DiagnosticRow(
                    label: 'Enabled Flags',
                    value: '$enabledFlags',
                    icon: Icons.check_circle_outline,
                  ),
                  const Divider(height: 20),
                  _DiagnosticRow(
                    label: 'Config Overrides',
                    value: '${settings.configOverrides.length} key(s)',
                    icon: Icons.tune_outlined,
                  ),
                  const Divider(height: 20),
                  _DiagnosticRow(
                    label: 'Storage Status',
                    value: context.read<StorageService>().isInitialized
                        ? 'Initialized'
                        : 'Not initialized',
                    icon: Icons.storage_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DiagnosticRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
