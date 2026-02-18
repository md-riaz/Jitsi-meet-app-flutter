import 'package:flutter/material.dart';

class MeetingService extends ChangeNotifier {
  bool _isInMeeting = false;
  String? _currentRoomName;

  bool get isInMeeting => _isInMeeting;
  String? get currentRoomName => _currentRoomName;

  void setMeetingState({required bool inMeeting, String? roomName}) {
    _isInMeeting = inMeeting;
    _currentRoomName = roomName;
    notifyListeners();
  }
}
