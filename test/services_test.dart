import 'package:flutter_test/flutter_test.dart';
import 'package:alora_meet/core/services/meeting_service.dart';
import 'package:alora_meet/core/services/storage_service.dart';

void main() {
  group('MeetingService', () {
    late MeetingService service;

    setUp(() {
      service = MeetingService();
    });

    test('initial state is not in meeting', () {
      expect(service.isInMeeting, false);
      expect(service.currentRoomName, isNull);
    });

    test('setMeetingState updates state and notifies listeners', () {
      bool notified = false;
      service.addListener(() => notified = true);

      service.setMeetingState(inMeeting: true, roomName: 'test-room');

      expect(service.isInMeeting, true);
      expect(service.currentRoomName, 'test-room');
      expect(notified, true);
    });
  });

  group('StorageService', () {
    late StorageService service;

    setUp(() {
      service = StorageService();
    });

    test('initial state is not initialized', () {
      expect(service.isInitialized, false);
    });

    test('initialize sets isInitialized and notifies listeners', () async {
      bool notified = false;
      service.addListener(() => notified = true);

      await service.initialize();

      expect(service.isInitialized, true);
      expect(notified, true);
    });
  });
}
