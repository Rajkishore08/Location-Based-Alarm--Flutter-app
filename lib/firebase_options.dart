import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPIA7VnE5560n1k1B-5UR2cjqcSq7CG_s',
    appId: '1:571013355552:android:ca98a348fc5efb8fed8445',
    messagingSenderId: '571013355552',
    projectId: 'smart-location-alaram',
    storageBucket: 'smart-location-alaram.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCRfTY-LOlKzXxA3vjDSfzOJ2qXuPZm4Uo',
    appId: '1:571013355552:web:cbc42b3c501aebb5ed8445',
    messagingSenderId: '571013355552',
    projectId: 'smart-location-alaram',
    authDomain: 'smart-location-alaram.firebaseapp.com',
    storageBucket: 'smart-location-alaram.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRfTY-LOlKzXxA3vjDSfzOJ2qXuPZm4Uo',
    appId: '1:571013355552:ios:ca98a348fc5efb8fed8445',
    messagingSenderId: '571013355552',
    projectId: 'smart-location-alaram',
    storageBucket: 'smart-location-alaram.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCRfTY-LOlKzXxA3vjDSfzOJ2qXuPZm4Uo',
    appId: '1:571013355552:ios:ca98a348fc5efb8fed8445',
    messagingSenderId: '571013355552',
    projectId: 'smart-location-alaram',
    storageBucket: 'smart-location-alaram.firebasestorage.app',
  );
}
