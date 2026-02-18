import 'package:flutter_test/flutter_test.dart';
import 'package:alora_meet/core/services/storage_service.dart';

void main() {
  group('StorageService', () {
    late StorageService service;

    setUp(() {
      service = StorageService();
    });

    test('initial state before initialization', () {
      expect(service.isInitialized, false);
      expect(service.profile, isNull);
      expect(service.meetingHistory, isEmpty);
    });

    test('default settings are AppSettings defaults', () {
      final settings = service.settings;
      expect(settings.serverURL, 'https://meet.jit.si');
      expect(settings.language, 'en');
      expect(settings.darkMode, true);
      expect(settings.displayName, 'Alora User');
      expect(settings.featureFlags.length, 36);
    });

    test('meetingHistory returns unmodifiable list', () {
      final history = service.meetingHistory;
      expect(() => history.add(null as dynamic), throwsUnsupportedError);
    });

    test('is a ChangeNotifier and supports listeners', () {
      expect(service.hasListeners, false);
      final callback = () {};
      service.addListener(callback);
      expect(service.hasListeners, true);
      service.removeListener(callback);
      expect(service.hasListeners, false);
    });
  });
}
