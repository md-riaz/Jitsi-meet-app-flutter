import 'package:flutter_test/flutter_test.dart';
import 'package:alora_meet/core/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    group('UserProfile.create()', () {
      test('creates profile with defaults', () {
        final profile = UserProfile.create();

        expect(profile.id, isNotEmpty);
        expect(profile.displayName, 'Alora User');
        expect(profile.email, '');
        expect(profile.avatarURL, isNull);
        expect(profile.createdAt, isA<DateTime>());
        expect(profile.lastActive, isA<DateTime>());
        expect(profile.totalMeetings, 0);
        expect(profile.totalMinutes, 0);
      });

      test('creates profile with custom values', () {
        final profile = UserProfile.create(
          displayName: 'Jane Doe',
          email: 'jane@example.com',
          avatarURL: 'https://avatar.com/jane.png',
        );

        expect(profile.displayName, 'Jane Doe');
        expect(profile.email, 'jane@example.com');
        expect(profile.avatarURL, 'https://avatar.com/jane.png');
      });

      test('generates unique IDs', () {
        final ids = List.generate(20, (_) => UserProfile.create().id);
        expect(ids.toSet().length, 20);
      });
    });

    group('copyWith', () {
      test('updates displayName only', () {
        final original = UserProfile.create(displayName: 'Old');
        final updated = original.copyWith(displayName: 'New');

        expect(updated.displayName, 'New');
        expect(updated.id, original.id);
        expect(updated.email, original.email);
        expect(updated.createdAt, original.createdAt);
      });

      test('preserves all fields when no arguments given', () {
        final original = UserProfile.create(
          displayName: 'Test',
          email: 'test@test.com',
        );
        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.displayName, original.displayName);
        expect(copied.email, original.email);
        expect(copied.avatarURL, original.avatarURL);
        expect(copied.createdAt, original.createdAt);
        expect(copied.lastActive, original.lastActive);
        expect(copied.totalMeetings, original.totalMeetings);
        expect(copied.totalMinutes, original.totalMinutes);
      });

      test('increments stat counters via copyWith', () {
        final profile = UserProfile.create();

        final after1 = profile.copyWith(
          totalMeetings: profile.totalMeetings + 1,
          totalMinutes: profile.totalMinutes + 30,
        );
        expect(after1.totalMeetings, 1);
        expect(after1.totalMinutes, 30);

        final after2 = after1.copyWith(
          totalMeetings: after1.totalMeetings + 1,
          totalMinutes: after1.totalMinutes + 45,
        );
        expect(after2.totalMeetings, 2);
        expect(after2.totalMinutes, 75);
      });
    });

    group('toJson / fromJson', () {
      test('round-trip serialization', () {
        final now = DateTime(2025, 6, 1, 10);
        final original = UserProfile(
          id: 'profile-123',
          displayName: 'Alice',
          email: 'alice@test.com',
          avatarURL: 'https://avatar.com/alice.png',
          createdAt: now,
          lastActive: now.add(const Duration(hours: 2)),
          totalMeetings: 15,
          totalMinutes: 450,
        );

        final json = original.toJson();
        final restored = UserProfile.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.displayName, original.displayName);
        expect(restored.email, original.email);
        expect(restored.avatarURL, original.avatarURL);
        expect(restored.createdAt, original.createdAt);
        expect(restored.lastActive, original.lastActive);
        expect(restored.totalMeetings, original.totalMeetings);
        expect(restored.totalMinutes, original.totalMinutes);
      });

      test('fromJson with defaults for optional fields', () {
        final json = {
          'id': 'id-1',
          'displayName': 'Bob',
          'createdAt': '2025-01-01T00:00:00.000',
          'lastActive': '2025-01-01T01:00:00.000',
        };
        final profile = UserProfile.fromJson(json);

        expect(profile.email, '');
        expect(profile.avatarURL, isNull);
        expect(profile.totalMeetings, 0);
        expect(profile.totalMinutes, 0);
      });

      test('fromJson with null optional fields', () {
        final json = {
          'id': 'id-2',
          'displayName': 'Carol',
          'createdAt': '2025-01-01T00:00:00.000',
          'lastActive': '2025-01-01T00:00:00.000',
          'email': null,
          'avatarURL': null,
          'totalMeetings': null,
          'totalMinutes': null,
        };
        final profile = UserProfile.fromJson(json);

        expect(profile.email, '');
        expect(profile.avatarURL, isNull);
        expect(profile.totalMeetings, 0);
        expect(profile.totalMinutes, 0);
      });
    });
  });
}
