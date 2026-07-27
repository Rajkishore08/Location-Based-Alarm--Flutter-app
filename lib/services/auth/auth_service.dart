import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      googleProvider.setCustomParameters({'prompt': 'select_account'});

      if (kIsWeb) {
        return await _auth.signInWithPopup(googleProvider);
      } else {
        return await _auth.signInWithProvider(googleProvider);
      }
    } catch (e) {
      debugPrint('Google Sign In Exception: $e');
      try {
        if (kIsWeb) {
          await _auth.signInWithRedirect(GoogleAuthProvider());
          return null;
        }
      } catch (_) {}
      return await _auth.signInAnonymously();
    }
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
