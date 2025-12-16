import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<QuerySnapshot>? _statsSubscription;

  int _totalCatatan = 0;
  int _totalSuka = 0;
  bool _isLoadingStats = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  int get totalCatatan => _totalCatatan;
  int get totalSuka => _totalSuka;
  bool get isLoadingStats => _isLoadingStats;

  AuthProvider() {
    _initAuthListener();
  }

  Map<String, dynamic>? userProfile;
  bool isLoadingProfile = false;

  User? get currentUser => _authService.currentUser;

  Future<void> loadUserProfile() async {
    if (currentUser == null) return;

    isLoadingProfile = true;
    notifyListeners();

    try {
      DocumentSnapshot doc =
      await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        Map<String, dynamic> firestoreData = doc.data() as Map<String, dynamic>;

        userProfile = {
          'uid': currentUser!.uid,
          'email': firestoreData['email'] ?? currentUser!.email ?? '',
          'nama': firestoreData['nama'] ?? currentUser!.displayName ?? '',
          'username': firestoreData['username'] ?? '',
          'sekolah': firestoreData['sekolah'] ?? '',
          'photoUrl': firestoreData['photoUrl'] ?? currentUser!.photoURL,
          'tanggalLahir': firestoreData['tanggalLahir'],
        };
      } else {
        userProfile = {
          'uid': currentUser!.uid,
          'email': currentUser!.email ?? '',
          'nama': currentUser!.displayName ?? '',
          'username': '',
          'sekolah': '',
          'photoUrl': currentUser!.photoURL,
        };
      }

      loadUserStats();

    } catch (e) {
      debugPrint("Error loading profile: $e");
    }

    isLoadingProfile = false;
    notifyListeners();
  }

  void loadUserStats() {
    _statsSubscription?.cancel();

    if (currentUser == null) return;

    _isLoadingStats = true;
    notifyListeners();

    _statsSubscription = _firestore
        .collection('notes')
        .where('authorId', isEqualTo: currentUser!.uid)
        .snapshots()
        .listen((notesSnapshot) async {

      int notesCount = notesSnapshot.docs.length;

      List<int> likesPerNote = await Future.wait(notesSnapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        int count = 0;

        if (data['likes'] != null && data['likes'] is List) {
          count = (data['likes'] as List).length;
        } else if (data['likedBy'] != null && data['likedBy'] is List) {
          count = (data['likedBy'] as List).length;
        } else if (data['likes'] is num) {
          count = (data['likes'] as num).toInt();
        }

        if (count == 0) {
          try {
            AggregateQuerySnapshot subLikes = await doc.reference.collection('likes').count().get();
            if (subLikes.count != null && subLikes.count! > 0) {
              count = subLikes.count!;
            } else {
              AggregateQuerySnapshot subLikedBy = await doc.reference.collection('likedBy').count().get();
              if (subLikedBy.count != null && subLikedBy.count! > 0) {
                count = subLikedBy.count!;
              }
            }
          } catch (_) {}
        }
        return count;
      }));

      int totalLikes = likesPerNote.fold(0, (sum, count) => sum + count);

      _totalCatatan = notesCount;
      _totalSuka = totalLikes;
      _isLoadingStats = false;
      notifyListeners();

    }, onError: (e) {
      debugPrint("Error listening to stats: $e");
      _isLoadingStats = false;
      notifyListeners();
    });
  }

  Future<void> updateProfile({
    required String nama,
    required String username,
    required String sekolah,
    DateTime? tanggalLahir,
  }) async {
    if (currentUser == null) return;

    await _firestore.collection('users').doc(currentUser!.uid).update({
      'nama': nama,
      'username': username,
      'sekolah': sekolah,
      'tanggalLahir': tanggalLahir,
    });

    await currentUser!.updateDisplayName(nama);
    await loadUserProfile();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;

      if (user == null) {
        userProfile = null;
        _totalCatatan = 0;
        _totalSuka = 0;
        _statsSubscription?.cancel();
      }

      notifyListeners();

      if (user != null) {
        debugPrint('✅ User logged in: ${user.email}');
        loadUserProfile();
      } else {
        debugPrint('❌ User logged out');
      }
    });
  }

  Future<bool> _executeAuth(
      Future<void> Function() operation, {
        String? errorPrefix,
      }) async {
    try {
      _setLoading(true);
      _clearError();
      await operation();
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('${errorPrefix ?? "Operation failed"}: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> _refreshUser() async {
    _user = _authService.currentUser;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    debugPrint('❌ Auth Error: $message');
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _executeAuth(
            () => _authService.signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        ),
        errorPrefix: 'Sign up gagal',
      );

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _executeAuth(
            () => _authService.signInWithEmail(email: email, password: password),
        errorPrefix: 'Sign in gagal',
      );


  Future<bool> sendPasswordResetEmail(String email) => _executeAuth(
        () => _authService.sendPasswordResetEmail(email),
    errorPrefix: 'Gagal mengirim email reset',
  );

  Future<bool> updateDisplayName(String displayName) async {
    final result = await _executeAuth(
          () => _authService.updateDisplayName(displayName),
      errorPrefix: 'Gagal update nama',
    );
    if (result) await _refreshUser();
    return result;
  }

  Future<bool> updatePassword(String newPassword) => _executeAuth(
        () => _authService.updatePassword(newPassword),
    errorPrefix: 'Gagal update password',
  );

  Future<void> signOut() async {
    _statsSubscription?.cancel();
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> reauthenticateWithEmail({
    required String email,
    required String password,
  }) =>
      _executeAuth(
            () => _authService.reauthenticateWithEmail(
          email: email,
          password: password,
        ),
        errorPrefix: 'Re-authentication gagal',
      );

  Future<void> logout() async {
    _statsSubscription?.cancel(); // Pastikan listener dimatikan
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> deleteAccount({
    required String email,
    required String password,
  }) =>
      _executeAuth(
            () => _authService.deleteAccount(
          email: email,
          password: password,
        ),
        errorPrefix: 'Hapus akun gagal',
      );

  Future<void> deleteUserAndAllDataFull(String password) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    _statsSubscription?.cancel();

    try {
      await reauthenticateWithEmail(
        email: currentUser!.email!,
        password: password,
      );
      final notesSnapshot = await _firestore
          .collection('notes')
          .where('authorId', isEqualTo: uid)
          .get();
      for (var doc in notesSnapshot.docs) {
        await doc.reference.delete();
      }
      final allNotesSnapshot = await _firestore.collection('notes').get();
      for (var doc in allNotesSnapshot.docs) {
        final data = doc.data();
        if (data['likes'] != null && data['likes'] is List) {
          List likes = List.from(data['likes']);
          if (likes.contains(uid)) {
            likes.remove(uid);
            await doc.reference.update({'likes': likes});
          }
        }
      }
      final commentsSnapshot = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in commentsSnapshot.docs) {
        await doc.reference.delete();
      }
      final reportsSnapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in reportsSnapshot.docs) {
        await doc.reference.delete();
      }
      final notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .get();

      for (var doc in notificationsSnapshot.docs) {
        await doc.reference.delete();
      }
      await _firestore.collection('users').doc(uid).delete();
      await deleteAccount(
        email: currentUser!.email!,
        password: password,
      );

      debugPrint('✅ Semua data user berhasil dihapus sepenuhnya.');
    } catch (e) {
      debugPrint('❌ Gagal hapus akun dan semua data: $e');
      rethrow;
    }
  }
  Map<String, dynamic>? userData;

  Future<void> loadUser() async {
    userData = await _authService.getUserData();
    notifyListeners();
  }

  Future<void> updateUser(Map<String, dynamic> newData) async {
    await _authService.updateUserData(newData);
    await loadUser();
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'photoUrl': photoUrl,
      });

      await currentUser!.updatePhotoURL(photoUrl);

      await loadUserProfile();
    } catch (e) {
      debugPrint("Gagal update foto profile: $e");
      rethrow;
    }
  }
}