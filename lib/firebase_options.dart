import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for windows');
      case TargetPlatform.linux:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for linux');
      default:
        return android;
    }
  }

  static String get _projectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? 'smart-location-alaram';
  static String get _storageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'smart-location-alaram.firebasestorage.app';
  static String get _messagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '571013355552';

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
      );

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? '',
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        authDomain: dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'] ?? 'smart-location-alaram.firebaseapp.com',
        storageBucket: _storageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
        appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
      );
}
