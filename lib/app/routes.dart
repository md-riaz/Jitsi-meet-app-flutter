import 'package:flutter/material.dart';
import 'package:alora_meet/features/dashboard/screens/dashboard_screen.dart';
import 'package:alora_meet/features/meeting/screens/meeting_screen.dart';
import 'package:alora_meet/features/settings/screens/settings_screen.dart';
import 'package:alora_meet/features/history/screens/history_screen.dart';
import 'package:alora_meet/features/settings/screens/profile_settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String dashboard = '/';
  static const String meeting = '/meeting';
  static const String settings = '/settings';
  static const String history = '/history';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes {
    return {
      dashboard: (_) => const DashboardScreen(),
      meeting: (_) => const MeetingScreen(),
      settings: (_) => const SettingsScreen(),
      history: (_) => const HistoryScreen(),
      profile: (_) => const ProfileSettingsScreen(),
    };
  }
}
