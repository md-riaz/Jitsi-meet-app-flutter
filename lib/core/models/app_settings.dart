class AppSettings {
  // General
  final String serverURL;
  final String language;
  final bool darkMode;

  // Profile
  final String displayName;
  final String email;
  final String? avatarURL;

  // Audio/Video Defaults
  final bool startWithAudioMuted;
  final bool startWithVideoMuted;
  final String videoResolution;
  final bool noiseSuppression;

  // Feature Flags
  final Map<String, bool> featureFlags;

  // Config Overrides
  final Map<String, dynamic> configOverrides;

  const AppSettings({
    this.serverURL = 'https://app.alorameet.com',
    this.language = 'en',
    this.darkMode = true,
    this.displayName = 'Alora User',
    this.email = '',
    this.avatarURL,
    this.startWithAudioMuted = false,
    this.startWithVideoMuted = false,
    this.videoResolution = '720',
    this.noiseSuppression = true,
    this.featureFlags = const {},
    this.configOverrides = const {},
  });

  static AppSettings defaultSettings() {
    return AppSettings(
      featureFlags: defaultFeatureFlags(),
    );
  }

  static Map<String, bool> defaultFeatureFlags() {
    return {
      'welcomepage.enabled': false,
      'prejoinpage.enabled': true,
      'chat.enabled': true,
      'reactions.enabled': true,
      'recording.enabled': true,
      'livestreaming.enabled': true,
      'raise-hand.enabled': true,
      'tile-view.enabled': true,
      'toolbox.enabled': true,
      'filmstrip.enabled': true,
      'kick-out.enabled': true,
      'video-share.enabled': true,
      'security-options.enabled': true,
      'android.screensharing.enabled': true,
      'ios.screensharing.enabled': true,
      'speakerstats.enabled': true,
      'overflow-menu.enabled': true,
      'pip.enabled': true,
      'notifications.enabled': true,
      'close-captions.enabled': true,
      'invite.enabled': true,
      'lobby-mode.enabled': true,
      'meeting-name.enabled': true,
      'meeting-password.enabled': true,
      'server-url-change.enabled': true,
      'settings.enabled': true,
      'help.enabled': true,
      'calendar.enabled': true,
      'call-integration.enabled': true,
      'car-mode.enabled': false,
      'conference-timer.enabled': true,
      'add-people.enabled': true,
      'breakout-rooms.enabled': true,
      'audio-only.enabled': false,
      'unsaferoomwarning.enabled': false,
      'fullscreen.enabled': true,
    };
  }

  Map<String, List<String>> get categorizedFlags {
    return {
      'Meeting Controls': [
        'chat.enabled',
        'reactions.enabled',
        'raise-hand.enabled',
        'kick-out.enabled',
        'video-share.enabled',
        'speakerstats.enabled',
        'meeting-name.enabled',
      ],
      'Views & Layout': [
        'tile-view.enabled',
        'filmstrip.enabled',
        'pip.enabled',
        'fullscreen.enabled',
      ],
      'Recording & Streaming': [
        'recording.enabled',
        'livestreaming.enabled',
      ],
      'Security': [
        'security-options.enabled',
        'lobby-mode.enabled',
        'meeting-password.enabled',
        'unsaferoomwarning.enabled',
      ],
      'Navigation': [
        'welcomepage.enabled',
        'prejoinpage.enabled',
        'settings.enabled',
        'help.enabled',
        'overflow-menu.enabled',
        'toolbox.enabled',
        'server-url-change.enabled',
      ],
      'Communication': [
        'invite.enabled',
        'add-people.enabled',
        'close-captions.enabled',
        'notifications.enabled',
      ],
      'Platform': [
        'android.screensharing.enabled',
        'ios.screensharing.enabled',
        'call-integration.enabled',
        'car-mode.enabled',
      ],
      'Other': [
        'calendar.enabled',
        'conference-timer.enabled',
        'breakout-rooms.enabled',
        'audio-only.enabled',
      ],
    };
  }

  AppSettings copyWith({
    String? serverURL,
    String? language,
    bool? darkMode,
    String? displayName,
    String? email,
    String? avatarURL,
    bool? startWithAudioMuted,
    bool? startWithVideoMuted,
    String? videoResolution,
    bool? noiseSuppression,
    Map<String, bool>? featureFlags,
    Map<String, dynamic>? configOverrides,
  }) {
    return AppSettings(
      serverURL: serverURL ?? this.serverURL,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarURL: avatarURL ?? this.avatarURL,
      startWithAudioMuted: startWithAudioMuted ?? this.startWithAudioMuted,
      startWithVideoMuted: startWithVideoMuted ?? this.startWithVideoMuted,
      videoResolution: videoResolution ?? this.videoResolution,
      noiseSuppression: noiseSuppression ?? this.noiseSuppression,
      featureFlags: featureFlags ?? Map<String, bool>.from(this.featureFlags),
      configOverrides:
          configOverrides ?? Map<String, dynamic>.from(this.configOverrides),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverURL': serverURL,
      'language': language,
      'darkMode': darkMode,
      'displayName': displayName,
      'email': email,
      'avatarURL': avatarURL,
      'startWithAudioMuted': startWithAudioMuted,
      'startWithVideoMuted': startWithVideoMuted,
      'videoResolution': videoResolution,
      'noiseSuppression': noiseSuppression,
      'featureFlags': featureFlags,
      'configOverrides': configOverrides,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final defaults = defaultFeatureFlags();
    final jsonFlags = json['featureFlags'] as Map<String, dynamic>?;
    if (jsonFlags != null) {
      for (final entry in jsonFlags.entries) {
        defaults[entry.key] = entry.value as bool;
      }
    }

    return AppSettings(
      serverURL: json['serverURL'] as String? ?? 'https://app.alorameet.com',
      language: json['language'] as String? ?? 'en',
      darkMode: json['darkMode'] as bool? ?? true,
      displayName: json['displayName'] as String? ?? 'Alora User',
      email: json['email'] as String? ?? '',
      avatarURL: json['avatarURL'] as String?,
      startWithAudioMuted: json['startWithAudioMuted'] as bool? ?? false,
      startWithVideoMuted: json['startWithVideoMuted'] as bool? ?? false,
      videoResolution: json['videoResolution'] as String? ?? '720',
      noiseSuppression: json['noiseSuppression'] as bool? ?? true,
      featureFlags: defaults,
      configOverrides: json['configOverrides'] != null
          ? Map<String, dynamic>.from(json['configOverrides'] as Map)
          : {},
    );
  }
}
