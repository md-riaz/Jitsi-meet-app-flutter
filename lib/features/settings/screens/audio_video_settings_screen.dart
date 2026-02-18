import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:alora_meet/core/services/storage_service.dart';

class AudioVideoSettingsScreen extends StatelessWidget {
  const AudioVideoSettingsScreen({super.key});

  static const _resolutions = ['180', '360', '480', '720', '1080'];

  Future<void> _save(BuildContext context,
      {bool? audioMuted,
      bool? videoMuted,
      String? resolution,
      bool? noiseSuppression}) async {
    final storage = context.read<StorageService>();
    final updated = storage.settings.copyWith(
      startWithAudioMuted: audioMuted,
      startWithVideoMuted: videoMuted,
      videoResolution: resolution,
      noiseSuppression: noiseSuppression,
    );
    await storage.saveSettings(updated);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<StorageService>().settings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Audio & Video')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.mic_off_outlined,
                      color: theme.colorScheme.primary),
                  title: const Text('Start with Audio Muted'),
                  subtitle: const Text('Microphone muted when joining'),
                  value: settings.startWithAudioMuted,
                  onChanged: (v) => _save(context, audioMuted: v),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: Icon(Icons.videocam_off_outlined,
                      color: theme.colorScheme.primary),
                  title: const Text('Start with Video Muted'),
                  subtitle: const Text('Camera off when joining'),
                  value: settings.startWithVideoMuted,
                  onChanged: (v) => _save(context, videoMuted: v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: Icon(Icons.noise_aware_outlined,
                      color: theme.colorScheme.primary),
                  title: const Text('Noise Suppression'),
                  subtitle:
                      const Text('Reduce background noise during calls'),
                  value: settings.noiseSuppression,
                  onChanged: (v) => _save(context, noiseSuppression: v),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Video Resolution',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                value: _resolutions.contains(settings.videoResolution)
                    ? settings.videoResolution
                    : '720',
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  icon: Icon(Icons.high_quality_outlined),
                ),
                items: _resolutions
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text('${r}p'),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) _save(context, resolution: v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
