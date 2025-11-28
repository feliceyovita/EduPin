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
        userProfile = doc.data() as Map<String, dynamic>;
      }

      await loadUserStats();

    } catch (e) {
      debugPrint("Error loading profile: $e");
    }

    isLoadingProfile = false;
    notifyListeners();
  }

  Future<void> loadUserStats() async {
    if (currentUser == null) return;

    _isLoadingStats = true;

    try {
      final QuerySnapshot notesQuery = await _firestore
          .collection('notes')
          .where('authorId', isEqualTo: currentUser!.uid)
          .get();

      int notesCount = notesQuery.docs.length;
      int likesCount = 0;

      for (var doc in notesQuery.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('likes') && data['likes'] is List) {
          likesCount += (data['likes'] as List).length;
        } else if (data.containsKey('likeCount') && data['likeCount'] is num) {
          likesCount += (data['likeCount'] as num).toInt();
        }
      }

      _totalCatatan = notesCount;
      _totalSuka = likesCount;

    } catch (e) {
      debugPrint("Error loading stats: $e");
    }

    _isLoadingStats = false;
    notifyListeners();
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

  Future<bool> signOut() => _executeAuth(
    _authService.signOut,
    errorPrefix: 'Sign out gagal',
  );

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