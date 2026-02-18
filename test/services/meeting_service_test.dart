import 'package:flutter_test/flutter_test.dart';
import 'package:alora_meet/core/services/meeting_service.dart';

void main() {
  group('MeetingService', () {
    late MeetingService service;

    setUp(() {
      service = MeetingService();
    });

    test('initial state is not in meeting', () {
      expect(service.isInMeeting, false);
      expect(service.currentRoomName, isNull);
      expect(service.currentMeeting, isNull);
      expect(service.meetingStartTime, isNull);
      expect(service.participantCount, 0);
    });

    group('generateRoomName', () {
      test('returns name matching expected format', () {
        final name = service.generateRoomName();
        expect(name, matches(RegExp(r'^alora-meet-\d{4}$')));
      });

      test('starts with alora-meet- prefix', () {
        final name = service.generateRoomName();
        expect(name.startsWith('alora-meet-'), true);
      });

      test('suffix is a 4-digit number between 1000 and 9999', () {
        for (var i = 0; i < 100; i++) {
          final name = service.generateRoomName();
          final suffix = int.parse(name.split('-').last);
          expect(suffix, greaterThanOrEqualTo(1000));
          expect(suffix, lessThanOrEqualTo(9999));
        }
      });

      test('produces different names across calls', () {
        final names = List.generate(50, (_) => service.generateRoomName());
        // With 50 random 4-digit suffixes, duplicates are unlikely but possible.
        // We just check that not ALL are the same.
        expect(names.toSet().length, greaterThan(1));
      });
    });

    test('is a ChangeNotifier and supports listeners', () {
      // Verify the service extends ChangeNotifier by checking listener APIs.
      expect(service.hasListeners, false);
      final callback = () {};
      service.addListener(callback);
      expect(service.hasListeners, true);
      service.removeListener(callback);
      expect(service.hasListeners, false);
    });
  });
}
