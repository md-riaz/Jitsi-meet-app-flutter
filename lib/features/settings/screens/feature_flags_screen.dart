import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/models/app_settings.dart';
import 'package:alora_meet/core/services/storage_service.dart';

class FeatureFlagsScreen extends StatefulWidget {
  const FeatureFlagsScreen({super.key});

  @override
  State<FeatureFlagsScreen> createState() => _FeatureFlagsScreenState();
}

class _FeatureFlagsScreenState extends State<FeatureFlagsScreen> {
  String _search = '';

  static const _categoryIcons = {
    'Meeting Controls': Icons.settings_remote_outlined,
    'Views & Layout': Icons.grid_view_outlined,
    'Recording & Streaming': Icons.fiber_manual_record_outlined,
    'Security': Icons.shield_outlined,
    'Navigation': Icons.menu_outlined,
    'Communication': Icons.chat_outlined,
    'Platform': Icons.devices_outlined,
    'Other': Icons.more_horiz,
  };

  String _readableLabel(String key) {
    return key
        .replaceAll('.enabled', '')
        .replaceAll('.', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) =>
            w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  Future<void> _toggleFlag(String key, bool value) async {
    final storage = context.read<StorageService>();
    final flags = Map<String, bool>.from(storage.settings.featureFlags)
      ..[key] = value;
    await storage.saveSettings(storage.settings.copyWith(featureFlags: flags));
  }

  Future<void> _setAll(bool value) async {
    final storage = context.read<StorageService>();
    final flags = Map<String, bool>.from(storage.settings.featureFlags);
    for (final key in flags.keys) {
      flags[key] = value;
    }
    await storage.saveSettings(storage.settings.copyWith(featureFlags: flags));
  }

  Future<void> _resetFlags() async {
    final storage = context.read<StorageService>();
    final defaults = AppSettings.defaultFeatureFlags();
    await storage
        .saveSettings(storage.settings.copyWith(featureFlags: defaults));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StorageService>().settings;
    final theme = Theme.of(context);
    final categories = settings.categorizedFlags;
    final flags = settings.featureFlags;

    final enabledCount = flags.values.where((v) => v).length;
    final totalCount = flags.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Flags'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              switch (v) {
                case 'all_on':
                  _setAll(true);
                case 'all_off':
                  _setAll(false);
                case 'reset':
                  _resetFlags();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'all_on', child: Text('Toggle All On')),
              const PopupMenuItem(
                  value: 'all_off', child: Text('Toggle All Off')),
              const PopupMenuItem(
                  value: 'reset', child: Text('Reset to Defaults')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary chip
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Chip(
                  avatar: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withAlpha(51),
                    child: Icon(Icons.flag, size: 14,
                        color: theme.colorScheme.primary),
                  ),
                  label: Text('$enabledCount / $totalCount enabled'),
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search flags...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // Flags list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: categories.entries.map((category) {
                final categoryName = category.key;
                final categoryKeys = category.value;
                final filteredKeys = categoryKeys.where((k) {
                  if (_search.isEmpty) return true;
                  final label = _readableLabel(k).toLowerCase();
                  return label.contains(_search.toLowerCase()) ||
                      k.toLowerCase().contains(_search.toLowerCase());
                }).toList();

                if (filteredKeys.isEmpty) {
                  return const SizedBox.shrink();
                }

                final enabledInCategory =
                    filteredKeys.where((k) => flags[k] == true).length;

                return _CategorySection(
                  icon: _categoryIcons[categoryName] ?? Icons.flag_outlined,
                  title: categoryName,
                  enabledCount: enabledInCategory,
                  totalCount: filteredKeys.length,
                  theme: theme,
                  children: filteredKeys.map((key) {
                    return SwitchListTile(
                      dense: true,
                      title: Text(_readableLabel(key)),
                      subtitle: Text(
                        key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(102),
                          fontSize: 11,
                        ),
                      ),
                      value: flags[key] ?? false,
                      onChanged: (v) => _toggleFlag(key, v),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final int enabledCount;
  final int totalCount;
  final ThemeData theme;
  final List<Widget> children;

  const _CategorySection({
    required this.icon,
    required this.title,
    required this.enabledCount,
    required this.totalCount,
    required this.theme,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ExpansionTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 22),
        title: Text(
          title,
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$enabledCount of $totalCount enabled',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(153),
          ),
        ),
        initiallyExpanded: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: children,
      ),
    );
  }
}
