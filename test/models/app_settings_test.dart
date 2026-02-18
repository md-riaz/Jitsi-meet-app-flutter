import 'package:flutter_test/flutter_test.dart';
import 'package:alora_meet/core/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    group('defaultSettings()', () {
      test('has correct default values', () {
        final settings = AppSettings.defaultSettings();

        expect(settings.serverURL, 'https://meet.jit.si');
        expect(settings.language, 'en');
        expect(settings.darkMode, true);
        expect(settings.displayName, 'Alora User');
        expect(settings.email, '');
        expect(settings.avatarURL, isNull);
        expect(settings.startWithAudioMuted, false);
        expect(settings.startWithVideoMuted, false);
        expect(settings.videoResolution, '720');
        expect(settings.noiseSuppression, true);
        expect(settings.featureFlags, isNotEmpty);
        expect(settings.configOverrides, isEmpty);
      });
    });

    group('defaultFeatureFlags()', () {
      test('returns exactly 36 flags', () {
        final flags = AppSettings.defaultFeatureFlags();
        expect(flags.length, 36);
      });

      test('all values are booleans', () {
        final flags = AppSettings.defaultFeatureFlags();
        for (final entry in flags.entries) {
          expect(entry.value, isA<bool>(),
              reason: '${entry.key} should be a bool');
        }
      });

      test('contains key expected flags', () {
        final flags = AppSettings.defaultFeatureFlags();
        expect(flags.containsKey('chat.enabled'), true);
        expect(flags.containsKey('recording.enabled'), true);
        expect(flags.containsKey('pip.enabled'), true);
        expect(flags.containsKey('welcomepage.enabled'), true);
      });
    });

    group('copyWith', () {
      test('updates scalar fields', () {
        final original = AppSettings.defaultSettings();
        final updated = original.copyWith(
          serverURL: 'https://custom.com',
          darkMode: false,
          displayName: 'Test User',
          videoResolution: '1080',
        );

        expect(updated.serverURL, 'https://custom.com');
        expect(updated.darkMode, false);
        expect(updated.displayName, 'Test User');
        expect(updated.videoResolution, '1080');
        // unchanged fields
        expect(updated.language, original.language);
        expect(updated.email, original.email);
        expect(updated.noiseSuppression, original.noiseSuppression);
      });

      test('deep copies featureFlags when not overridden', () {
        final original = AppSettings.defaultSettings();
        final copied = original.copyWith();

        // Mutating the copy should not affect the original
        copied.featureFlags['chat.enabled'] = false;
        expect(original.featureFlags['chat.enabled'], true);
      });

      test('deep copies configOverrides when not overridden', () {
        const original = AppSettings(
          configOverrides: {'key': 'value'},
        );
        final copied = original.copyWith();

        copied.configOverrides['key'] = 'modified';
        expect(original.configOverrides['key'], 'value');
      });

      test('replaces featureFlags when overridden', () {
        final original = AppSettings.defaultSettings();
        final newFlags = {'custom.flag': true};
        final updated = original.copyWith(featureFlags: newFlags);

        expect(updated.featureFlags, {'custom.flag': true});
        expect(original.featureFlags.length, 36);
      });
    });

    group('toJson / fromJson', () {
      test('round-trip serialization', () {
        const original = AppSettings(
          serverURL: 'https://my.server.com',
          language: 'fr',
          darkMode: false,
          displayName: 'Jean',
          email: 'jean@example.com',
          avatarURL: 'https://avatar.com/jean.png',
          startWithAudioMuted: true,
          startWithVideoMuted: true,
          videoResolution: '480',
          noiseSuppression: false,
          featureFlags: {'chat.enabled': false, 'pip.enabled': true},
          configOverrides: {'maxParticipants': 10},
        );

        final json = original.toJson();
        final restored = AppSettings.fromJson(json);

        expect(restored.serverURL, original.serverURL);
        expect(restored.language, original.language);
        expect(restored.darkMode, original.darkMode);
        expect(restored.displayName, original.displayName);
        expect(restored.email, original.email);
        expect(restored.avatarURL, original.avatarURL);
        expect(restored.startWithAudioMuted, original.startWithAudioMuted);
        expect(restored.startWithVideoMuted, original.startWithVideoMuted);
        expect(restored.videoResolution, original.videoResolution);
        expect(restored.noiseSuppression, original.noiseSuppression);
        expect(restored.configOverrides, original.configOverrides);
        // featureFlags are merged with defaults, so custom flags override
        expect(restored.featureFlags['chat.enabled'], false);
        expect(restored.featureFlags['pip.enabled'], true);
      });

      test('fromJson merges defaults with provided flags', () {
        final json = {
          'featureFlags': {
            'chat.enabled': false,
          },
        };
        final settings = AppSettings.fromJson(json);

        // Provided flag is overridden
        expect(settings.featureFlags['chat.enabled'], false);
        // Default flags that were not in JSON still present
        expect(settings.featureFlags['recording.enabled'], true);
        expect(settings.featureFlags.length, 36);
      });

      test('fromJson with empty map uses all defaults', () {
        final settings = AppSettings.fromJson({});

        expect(settings.serverURL, 'https://meet.jit.si');
        expect(settings.language, 'en');
        expect(settings.darkMode, true);
        expect(settings.displayName, 'Alora User');
        expect(settings.featureFlags.length, 36);
      });
    });

    group('categorizedFlags', () {
      test('returns all 8 categories', () {
        final settings = AppSettings.defaultSettings();
        final categories = settings.categorizedFlags;

        expect(categories.length, 8);
        expect(categories.keys, containsAll([
          'Meeting Controls',
          'Views & Layout',
          'Recording & Streaming',
          'Security',
          'Navigation',
          'Communication',
          'Platform',
          'Other',
        ]));
      });

      test('all flags appear in exactly one category', () {
        final settings = AppSettings.defaultSettings();
        final categories = settings.categorizedFlags;
        final allFlags = AppSettings.defaultFeatureFlags().keys.toSet();

        final categorizedFlagsList = <String>[];
        for (final flags in categories.values) {
          categorizedFlagsList.addAll(flags);
        }

        // Every flag appears at least once
        expect(categorizedFlagsList.toSet(), allFlags);
        // No duplicates — each flag in exactly one category
        expect(categorizedFlagsList.length, categorizedFlagsList.toSet().length);
      });
    });
  });
}
