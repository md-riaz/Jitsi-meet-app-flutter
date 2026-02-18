import 'package:flutter_test/flutter_test.dart';
import 'package:alora_meet/core/models/meeting.dart';

void main() {
  group('Meeting', () {
    group('Meeting.create()', () {
      test('creates meeting with all fields', () {
        final scheduled = DateTime(2025, 6, 15, 14);
        final meeting = Meeting.create(
          roomName: 'test-room',
          subject: 'Daily Standup',
          password: 'secret',
          scheduledFor: scheduled,
          serverURL: 'https://custom.server.com',
          creatorName: 'Alice',
          creatorEmail: 'alice@example.com',
        );

        expect(meeting.id, isNotEmpty);
        expect(meeting.roomName, 'test-room');
        expect(meeting.subject, 'Daily Standup');
        expect(meeting.password, 'secret');
        expect(meeting.createdAt, isA<DateTime>());
        expect(meeting.scheduledFor, scheduled);
        expect(meeting.serverURL, 'https://custom.server.com');
        expect(meeting.creatorName, 'Alice');
        expect(meeting.creatorEmail, 'alice@example.com');
        expect(meeting.durationMinutes, isNull);
      });

      test('uses default serverURL when not provided', () {
        final meeting = Meeting.create(roomName: 'room');
        expect(meeting.serverURL, 'https://app.alorameet.com');
      });

      test('sets optional fields to null when not provided', () {
        final meeting = Meeting.create(roomName: 'room');
        expect(meeting.subject, isNull);
        expect(meeting.password, isNull);
        expect(meeting.scheduledFor, isNull);
        expect(meeting.creatorName, isNull);
        expect(meeting.creatorEmail, isNull);
      });

      test('generates unique IDs across multiple calls', () {
        final ids = List.generate(50, (_) => Meeting.create(roomName: 'r').id);
        expect(ids.toSet().length, 50);
      });
    });

    group('copyWith', () {
      test('copies with updated roomName', () {
        final original = Meeting.create(roomName: 'old-room');
        final copied = original.copyWith(roomName: 'new-room');

        expect(copied.roomName, 'new-room');
        expect(copied.id, original.id);
        expect(copied.createdAt, original.createdAt);
      });

      test('copies with updated durationMinutes', () {
        final original = Meeting.create(roomName: 'room');
        final copied = original.copyWith(durationMinutes: 45);

        expect(copied.durationMinutes, 45);
        expect(copied.roomName, 'room');
      });

      test('copies with multiple updated fields', () {
        final original = Meeting.create(roomName: 'room');
        final copied = original.copyWith(
          subject: 'New Subject',
          password: 'pw',
          serverURL: 'https://other.com',
        );

        expect(copied.subject, 'New Subject');
        expect(copied.password, 'pw');
        expect(copied.serverURL, 'https://other.com');
        expect(copied.id, original.id);
      });

      test('preserves all fields when no arguments given', () {
        final original = Meeting.create(
          roomName: 'room',
          subject: 'Sub',
          password: 'pw',
          creatorName: 'Bob',
          creatorEmail: 'bob@test.com',
        );
        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.roomName, original.roomName);
        expect(copied.subject, original.subject);
        expect(copied.password, original.password);
        expect(copied.createdAt, original.createdAt);
        expect(copied.serverURL, original.serverURL);
        expect(copied.creatorName, original.creatorName);
        expect(copied.creatorEmail, original.creatorEmail);
      });
    });

    group('toJson / fromJson', () {
      test('round-trip with all fields', () {
        final scheduled = DateTime(2025, 3, 10, 9, 30);
        final original = Meeting(
          id: 'abc-123',
          roomName: 'test-room',
          subject: 'Sync',
          password: 'pass',
          createdAt: DateTime(2025, 1),
          scheduledFor: scheduled,
          serverURL: 'https://custom.jit.si',
          creatorName: 'Charlie',
          creatorEmail: 'charlie@test.com',
          durationMinutes: 60,
        );

        final json = original.toJson();
        final restored = Meeting.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.roomName, original.roomName);
        expect(restored.subject, original.subject);
        expect(restored.password, original.password);
        expect(restored.createdAt, original.createdAt);
        expect(restored.scheduledFor, original.scheduledFor);
        expect(restored.serverURL, original.serverURL);
        expect(restored.creatorName, original.creatorName);
        expect(restored.creatorEmail, original.creatorEmail);
        expect(restored.durationMinutes, original.durationMinutes);
      });

      test('fromJson with minimal required fields', () {
        final json = {
          'id': 'min-id',
          'roomName': 'minimal-room',
          'createdAt': '2025-01-01T00:00:00.000',
        };
        final meeting = Meeting.fromJson(json);

        expect(meeting.id, 'min-id');
        expect(meeting.roomName, 'minimal-room');
        expect(meeting.serverURL, 'https://app.alorameet.com');
        expect(meeting.subject, isNull);
        expect(meeting.password, isNull);
        expect(meeting.scheduledFor, isNull);
        expect(meeting.creatorName, isNull);
        expect(meeting.creatorEmail, isNull);
        expect(meeting.durationMinutes, isNull);
      });

      test('fromJson with null optional fields', () {
        final json = {
          'id': 'id-1',
          'roomName': 'room-1',
          'createdAt': '2025-06-01T12:00:00.000',
          'subject': null,
          'password': null,
          'scheduledFor': null,
          'serverURL': null,
          'creatorName': null,
          'creatorEmail': null,
          'durationMinutes': null,
        };
        final meeting = Meeting.fromJson(json);

        expect(meeting.serverURL, 'https://app.alorameet.com');
        expect(meeting.subject, isNull);
        expect(meeting.password, isNull);
        expect(meeting.scheduledFor, isNull);
        expect(meeting.durationMinutes, isNull);
      });
    });
  });
}
