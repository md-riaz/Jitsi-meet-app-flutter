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

    test('generateRoomName returns valid room name', () {
      final name = service.generateRoomName();
      expect(name, matches(RegExp(r'^alora-meet-\d{4}$')));
    });
  });
}
