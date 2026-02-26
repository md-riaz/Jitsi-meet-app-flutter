import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:alora_meet/core/services/storage_service.dart';
import 'package:alora_meet/features/settings/screens/general_settings_screen.dart';
import 'package:alora_meet/features/settings/screens/profile_settings_screen.dart';
import 'package:alora_meet/features/settings/screens/audio_video_settings_screen.dart';
import 'package:alora_meet/features/settings/screens/feature_flags_screen.dart';
import 'package:alora_meet/features/settings/screens/advanced_settings_screen.dart';
import 'package:alora_meet/features/settings/widgets/settings_section_tile.dart';
import 'package:alora_meet/shared/widgets/main_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _searchQuery = '';

  bool _matches(String label) {
    if (_searchQuery.isEmpty) return true;
    return label.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final storageService = context.watch<StorageService>();
    final settings = storageService.settings;
    final theme = Theme.of(context);

    final enabledFlags =
        settings.featureFlags.values.where((v) => v).length;
    final totalFlags = settings.featureFlags.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text(
              'Configure your meeting experience',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search settings...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(height: 4),

          // General
          if (_matches('general') ||
              _matches('server') ||
              _matches('language') ||
              _matches('theme'))
            _buildSection(
              context,
              header: 'General',
              children: [
                SettingsSectionTile(
                  icon: Icons.dns_outlined,
                  title: 'General',
                   subtitle: settings.serverURL,
                  trailing: Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withAlpha(102)),
                  onTap: () => _navigate(
                      context, const GeneralSettingsScreen()),
                ),
              ],
            ),

          // Profile
          if (_matches('profile') ||
              _matches('display') ||
              _matches('email') ||
              _matches('avatar'))
            _buildSection(
              context,
              header: 'Profile',
              children: [
                SettingsSectionTile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: settings.displayName.isNotEmpty
                      ? settings.displayName
                      : 'Not configured',
                  trailing: Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withAlpha(102)),
                  onTap: () => _navigate(
                      context, const ProfileSettingsScreen()),
                ),
              ],
            ),

          // Audio & Video
          if (_matches('audio') ||
              _matches('video') ||
              _matches('resolution') ||
              _matches('noise') ||
              _matches('mute'))
            _buildSection(
              context,
              header: 'Audio & Video',
              children: [
                SettingsSectionTile(
                  icon: Icons.videocam_outlined,
                  title: 'Audio & Video',
                  subtitle: '${settings.videoResolution}p · '
                      '${settings.noiseSuppression ? "Noise suppression on" : "Noise suppression off"}',
                  trailing: Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withAlpha(102)),
                  onTap: () => _navigate(
                      context, const AudioVideoSettingsScreen()),
                ),
              ],
            ),

          // Feature Flags
          if (_matches('feature') || _matches('flag'))
            _buildSection(
              context,
              header: 'Feature Flags',
              children: [
                SettingsSectionTile(
                  icon: Icons.flag_outlined,
                  title: 'Feature Flags',
                  subtitle: '$enabledFlags of $totalFlags enabled',
                  trailing: Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withAlpha(102)),
                  onTap: () =>
                      _navigate(context, const FeatureFlagsScreen()),
                ),
              ],
            ),

          // Advanced
          if (_matches('advanced') ||
              _matches('config') ||
              _matches('override') ||
              _matches('json') ||
              _matches('export'))
            _buildSection(
              context,
              header: 'Advanced',
              children: [
                SettingsSectionTile(
                  icon: Icons.tune_outlined,
                  title: 'Advanced',
                  subtitle: 'Config overrides, import & export',
                  trailing: Icon(Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withAlpha(102)),
                  onTap: () => _navigate(
                      context, const AdvancedSettingsScreen()),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Support & Legal
          if (_matches('help') ||
              _matches('terms') ||
              _matches('privacy') ||
              _matches('support') ||
              _searchQuery.isEmpty)
            _buildSection(
              context,
              header: 'Support & Legal',
              children: [
                SettingsSectionTile(
                  icon: Icons.help_outline,
                  title: 'Help',
                  subtitle: 'Contact & support',
                  trailing: Icon(Icons.open_in_new,
                      size: 18,
                      color: theme.colorScheme.onSurface.withAlpha(102)),
                  onTap: () => _launchUrl(
                      context, 'https://www.alorameet.com/Contact.html'),
                ),
                SettingsSectionTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'View our terms',
                  trailing: Icon(Icons.open_in_new,
                      size: 18,
                      color: theme.colorScheme.onSurface.withAlpha(102)),
                  onTap: () => _launchUrl(context,
                      'https://www.alorameet.com/Legal/Terms.html'),
                ),
                SettingsSectionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  trailing: Icon(Icons.open_in_new,
                      size: 18,
                      color: theme.colorScheme.onSurface.withAlpha(102)),
                  onTap: () => _launchUrl(context,
                      'https://www.alorameet.com/Legal/Privacy.html'),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Reset button
          if (_matches('reset') || _searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Reset to Defaults'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _confirmReset(context),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String header,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            header,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open link. Please check your internet connection or try again later.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all settings to their default values. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<StorageService>().resetSettings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to defaults')),
        );
      }
    }
  }

}
