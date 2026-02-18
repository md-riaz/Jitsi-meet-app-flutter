import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:alora_meet/app/app.dart';
import 'package:alora_meet/core/services/meeting_service.dart';
import 'package:alora_meet/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final storageService = StorageService();
  await storageService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: storageService),
        ChangeNotifierProvider(create: (_) => MeetingService()),
      ],
      child: const AloraMeetApp(),
    ),
  );
}
