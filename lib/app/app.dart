import 'package:flutter/material.dart';
import 'package:alora_meet/app/theme.dart';
import 'package:alora_meet/app/routes.dart';

class AloraMeetApp extends StatelessWidget {
  const AloraMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alora Meet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.dashboard,
      routes: AppRoutes.routes,
    );
  }
}
