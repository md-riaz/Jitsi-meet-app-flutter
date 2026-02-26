import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/app_settings.dart';
import '../models/meeting.dart';
import '../models/user_profile.dart';

class StorageService extends ChangeNotifier {
  static const String _settingsBox = 'settings';
  static const String _meetingsBox = 'meetings';
  static const String _profileBox = 'profile';

  static const String _settingsKey = 'app_settings';
  static const String _profileKey = 'user_profile';
  static const String _meetingsKey = 'meeting_history';
  static const String _apiTokenKey = 'api_token';

  static const int _maxMeetingHistory = 100;

  late Box _settingsBoxInstance;
  late Box _meetingsBoxInstance;
  late Box _profileBoxInstance;

  AppSettings _settings = AppSettings.defaultSettings();
  UserProfile? _profile;
  List<Meeting> _meetingHistory = [];
  bool _isInitialized = false;
  String? _apiToken;

  AppSettings get settings => _settings;
  UserProfile? get profile => _profile;
  List<Meeting> get meetingHistory => List.unmodifiable(_meetingHistory);
  bool get isInitialized => _isInitialized;
  String? get apiToken => _apiToken;

  Future<void> initialize() async {
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
    _meetingsBoxInstance = await Hive.openBox(_meetingsBox);
    _profileBoxInstance = await Hive.openBox(_profileBox);

    _settings = _loadSettings();
    _profile = _loadProfile();
    _meetingHistory = _loadMeetings();
    _apiToken = _settingsBoxInstance.get(_apiTokenKey) as String?;

    if (_profile == null) {
      _profile = UserProfile.create();
      await _saveProfile();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
    await _settingsBoxInstance.put(
      _settingsKey,
      jsonEncode(settings.toJson()),
    );
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    await _saveProfile();
    notifyListeners();
  }

  Future<void> addMeeting(Meeting meeting) async {
    try {
      _meetingHistory.insert(0, meeting);
      if (_meetingHistory.length > _maxMeetingHistory) {
        _meetingHistory = _meetingHistory.sublist(0, _maxMeetingHistory);
      }
      await _saveMeetings();
      notifyListeners();
    } catch (e) {
      // Rollback on error
      _meetingHistory.removeWhere((m) => m.id == meeting.id);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMeeting(Meeting meeting) async {
    final index = _meetingHistory.indexWhere((m) => m.id == meeting.id);
    if (index != -1) {
      final oldMeeting = _meetingHistory[index];
      try {
        _meetingHistory[index] = meeting;
        await _saveMeetings();
        notifyListeners();
      } catch (e) {
        // Rollback on error
        _meetingHistory[index] = oldMeeting;
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> deleteMeeting(String meetingId) async {
    final index = _meetingHistory.indexWhere((m) => m.id == meetingId);
    if (index != -1) {
      final removedMeeting = _meetingHistory[index];
      try {
        _meetingHistory.removeAt(index);
        await _saveMeetings();
        notifyListeners();
      } catch (e) {
        // Rollback on error
        _meetingHistory.insert(index, removedMeeting);
        notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> clearHistory() async {
    final oldHistory = List<Meeting>.from(_meetingHistory);
    try {
      _meetingHistory.clear();
      await _saveMeetings();
      notifyListeners();
    } catch (e) {
      // Rollback on error
      _meetingHistory = oldHistory;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> resetSettings() async {
    _settings = AppSettings.defaultSettings();
    await _settingsBoxInstance.put(
      _settingsKey,
      jsonEncode(_settings.toJson()),
    );
    notifyListeners();
  }

  Future<void> saveApiToken(String? token) async {
    _apiToken = token;
    if (token == null || token.isEmpty) {
      await _settingsBoxInstance.delete(_apiTokenKey);
    } else {
      await _settingsBoxInstance.put(_apiTokenKey, token);
    }
    notifyListeners();
  }

  // Private helpers

  AppSettings _loadSettings() {
    final raw = _settingsBoxInstance.get(_settingsKey);
    if (raw == null) return AppSettings.defaultSettings();
    final map = jsonDecode(raw as String) as Map<String, dynamic>;
    return AppSettings.fromJson(map);
  }

  UserProfile? _loadProfile() {
    final raw = _profileBoxInstance.get(_profileKey);
    if (raw == null) return null;
    final map = jsonDecode(raw as String) as Map<String, dynamic>;
    return UserProfile.fromJson(map);
  }

  List<Meeting> _loadMeetings() {
    final raw = _meetingsBoxInstance.get(_meetingsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw as String) as List<dynamic>;
    return list
        .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveProfile() async {
    if (_profile != null) {
      await _profileBoxInstance.put(
        _profileKey,
        jsonEncode(_profile!.toJson()),
      );
    }
  }

  Future<void> _saveMeetings() async {
    final list = _meetingHistory.map((m) => m.toJson()).toList();
    await _meetingsBoxInstance.put(_meetingsKey, jsonEncode(list));
  }
}
