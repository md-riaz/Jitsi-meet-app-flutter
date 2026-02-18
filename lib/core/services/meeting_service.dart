import 'dart:math';

import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/meeting.dart';
import 'jitsi_service.dart';
import 'storage_service.dart';

class MeetingService extends ChangeNotifier {
  static final Random _random = Random();
  final JitsiService _jitsiService = JitsiService();

  bool _isInMeeting = false;
  String? _currentRoomName;
  Meeting? _currentMeeting;
  DateTime? _meetingStartTime;
  int _participantCount = 0;

  bool get isInMeeting => _isInMeeting;
  String? get currentRoomName => _currentRoomName;
  Meeting? get currentMeeting => _currentMeeting;
  DateTime? get meetingStartTime => _meetingStartTime;
  int get participantCount => _participantCount;

  Future<void> joinMeeting({
    required Meeting meeting,
    required AppSettings settings,
    required StorageService storageService,
    Function(String error)? onError,
  }) async {
    try {
      _isInMeeting = true;
      _currentRoomName = meeting.roomName;
      _currentMeeting = meeting;
      _participantCount = 0;
      notifyListeners();

      await storageService.addMeeting(meeting);

      await _jitsiService.joinMeeting(
        meeting: meeting,
        settings: settings,
        onConferenceJoined: (url) {
          _meetingStartTime = DateTime.now();
          notifyListeners();
        },
        onConferenceTerminated: (url) async {
          try {
            int? durationMinutes;
            if (_meetingStartTime != null) {
              final duration = DateTime.now().difference(_meetingStartTime!);
              durationMinutes = duration.inMinutes;
            }

            final updatedMeeting = meeting.copyWith(
              durationMinutes: durationMinutes,
            );
            await storageService.updateMeeting(updatedMeeting);
          } catch (e) {
            // Log but don't fail if we can't update meeting history
            debugPrint('Error updating meeting history: $e');
          } finally {
            _isInMeeting = false;
            _currentRoomName = null;
            _currentMeeting = null;
            _meetingStartTime = null;
            _participantCount = 0;
            notifyListeners();
          }
        },
        onParticipantJoined: (data) {
          _participantCount++;
          notifyListeners();
        },
        onParticipantLeft: (data) {
          if (_participantCount > 0) {
            _participantCount--;
            notifyListeners();
          }
        },
        onError: (error) {
          _isInMeeting = false;
          _currentRoomName = null;
          _currentMeeting = null;
          _participantCount = 0;
          notifyListeners();
          onError?.call(error);
        },
      );
    } catch (e) {
      _isInMeeting = false;
      _currentRoomName = null;
      _currentMeeting = null;
      _participantCount = 0;
      notifyListeners();
      
      final errorMessage = e.toString();
      onError?.call(errorMessage);
      rethrow;
    }
  }

  Future<void> leaveMeeting() async {
    try {
      await _jitsiService.hangUp();
    } catch (e) {
      debugPrint('Error leaving meeting: $e');
      // Even if hangUp fails, reset the state
      _isInMeeting = false;
      _currentRoomName = null;
      _currentMeeting = null;
      _meetingStartTime = null;
      _participantCount = 0;
      notifyListeners();
    }
  }

  String generateRoomName() {
    final suffix = _random.nextInt(9000) + 1000;
    return 'alora-meet-$suffix';
  }
}
