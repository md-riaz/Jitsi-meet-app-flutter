import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alora_meet/app/theme.dart';
import 'package:alora_meet/app/routes.dart';
import 'package:alora_meet/core/services/storage_service.dart';

class AloraMeetApp extends StatelessWidget {
  const AloraMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageService>(
      builder: (context, storage, _) {
        return MaterialApp(
          title: 'Alora Meet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: storage.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.dashboard,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
