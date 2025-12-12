import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
        await credential.user?.reload();
      }

      // SIMPAN STATUS LOGIN
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot.data();
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update(data);
  }
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  // ================================
  // RESET PASSWORD
  // ================================
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to send reset email: ${e.toString()}');
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    await _updateUserProfile(() async {
      await _requireUser().updateDisplayName(displayName.trim());
    }, 'display name');
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _requireUser().updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to update password: ${e.toString()}');
    }
  }

  Future<void> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password,
      );
      await _requireUser().reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Re-authentication failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    await signOut();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = _requireUser();

      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      await _firestore.collection("users").doc(user.uid).delete();

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  Future<void> _updateUserProfile(
      Future<void> Function() updateFn,
      String fieldName,
      ) async {
    try {
      await updateFn();
      await _requireUser().reload();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to update $fieldName: ${e.toString()}');
    }
  }

  User _requireUser() {
    final user = currentUser;
    if (user == null) {
      throw AuthException('No user is currently signed in');
    }
    return user;
  }

  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return AuthException('Password terlalu lemah. Minimal 6 karakter.');
      case 'email-already-in-use':
        return AuthException('Email sudah terdaftar.');
      case 'user-not-found':
        return AuthException('Email tidak ditemukan.');
      case 'wrong-password':
        return AuthException('Password salah.');
      case 'invalid-credential':
        return AuthException('Email atau password salah.');
      case 'invalid-email':
        return AuthException('Format email tidak valid.');
      case 'too-many-requests':
        return AuthException('Terlalu banyak percobaan.');
      case 'requires-recent-login':
        return AuthException('Silakan login ulang.');
      case 'network-request-failed':
        return AuthException('Tidak ada koneksi internet.');
      default:
        return AuthException('Error: ${e.message ?? e.code}');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
