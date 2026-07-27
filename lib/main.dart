import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/alarm/alarm_service.dart';
import 'services/storage/local_storage_service.dart';
import 'shared/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env) if present
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Graceful fallback when .env is omitted in build environment
  }

  // Initialize Firebase Core
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init note: $e');
  }

  // Initialize storage service
  final storageService = await LocalStorageService.init();

  // Initialize alarm notification channels
  final alarmService = AlarmService();
  await alarmService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        alarmServiceProvider.overrideWithValue(alarmService),
      ],
      child: const SmartRouteAlertApp(),
    ),
  );
}
