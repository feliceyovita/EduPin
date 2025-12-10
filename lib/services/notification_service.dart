import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addNotification({
    required String targetUserId,
    required String message,
    required String type,
    String? noteId,
    String? boardId,
    int? milestone,
    String? actorId,
  }) async {
    // default actor: current user
    actorId ??= _auth.currentUser?.uid;

    if (actorId == null) return;

    await _db
        .collection('users')
        .doc(targetUserId)
        .collection('notifications')
        .add({
      'actorId': actorId, // supaya bisa ambil foto profil real time
      'message': message,
      'type': type,
      'noteId': noteId,
      'boardId': boardId,
      'milestone': milestone,
      'timestamp': FieldValue.serverTimestamp(),
      'isNew': true,
    });
  }

  /// set notifikasi jadi "dibaca"
  Future<void> markAsRead({
    required String targetUserId,
    required String notificationId,
  }) async {
    await _db
        .collection('users')
        .doc(targetUserId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isNew': false});
  }

}
