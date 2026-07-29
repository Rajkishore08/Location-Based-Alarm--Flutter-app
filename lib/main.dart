import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/alarm/alarm_service.dart';
import 'services/storage/local_storage_service.dart';
import 'shared/providers/app_providers.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Prevent GoogleFonts from failing when offline on mobile launch
    GoogleFonts.config.allowRuntimeFetching = true;

    // Global Flutter Error Handler (prevents app crash)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('Global Flutter Framework Error: ${details.exception}');
    };

    // Safe Local Storage Service Initialization
    LocalStorageService? storageService;
    try {
      storageService = await LocalStorageService.init();
    } catch (e) {
      debugPrint('LocalStorageService init note: $e');
    }

    // Safe Alarm Service Initialization
    final alarmService = AlarmService();
    try {
      await alarmService.initialize();
    } catch (e) {
      debugPrint('AlarmService init note: $e');
    }

    // Safe Dotenv Loader
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint('Dotenv init note: $e');
    }

    // Safe Firebase Core Initialization
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase init note: $e');
    }

    runApp(
      ProviderScope(
        overrides: [
          if (storageService != null) storageServiceProvider.overrideWithValue(storageService),
          alarmServiceProvider.overrideWithValue(alarmService),
        ],
        child: const SmartRouteAlertApp(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('Uncaught Async Error: $error\n$stackTrace');
  });
}
