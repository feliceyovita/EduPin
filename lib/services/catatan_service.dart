import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_details.dart';

class NotesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> migrateLikes({
    required String noteId,
    required List<String> userIds,
  }) async {
    final batch = _db.batch();
    final likesRef = _db
        .collection('notes')
        .doc(noteId)
        .collection('likes');

    for (final uid in userIds) {
      batch.set(likesRef.doc(uid), {
        'userId': uid,
        'likedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ======================================================
  // BAGIAN 1: CRUD CATATAN
  // ======================================================
  Future<DocumentReference> createNote(Map<String, dynamic> data) async {
    data['createdAt'] ??= FieldValue.serverTimestamp();
    return await _db.collection('notes').add(data);
  }

  Stream<List<NoteDetail>> streamNotes() {
    return _db
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => NoteDetail.fromFirestore(d)).toList());
  }

  Future<NoteDetail> getNoteById(String noteId) async {
    final doc = await _db.collection('notes').doc(noteId).get();
    if (!doc.exists) {
      throw Exception("Note dengan ID $noteId tidak ditemukan");
    }
    return NoteDetail.fromFirestore(doc);
  }

  Future<void> updateNote(String noteId, Map<String, dynamic> data) async {
    await _db.collection('notes').doc(noteId).update(data);
  }

  // ======================================================
  // BAGIAN 2: PIN / SIMPAN
  // ======================================================
  Future<void> simpanKePin(String noteId, String namaKoleksi) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login");

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .doc(noteId)
        .set({
      'noteId': noteId,
      'collection': namaKoleksi,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hapusPin(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .doc(noteId)
        .delete();
  }

  Future<bool> isPinned(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .doc(noteId)
        .get();

    return doc.exists;
  }

  // ======================================================
  // BAGIAN 3: BOARD
  // ======================================================
  Stream<QuerySnapshot> streamKoleksi() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('boards')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> buatPapanBaru(String namaPapan) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login");

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('boards')
        .add({
      'name': namaPapan,
      'createdAt': FieldValue.serverTimestamp(),
      'coverImage': '',
    });
  }

  Future<List<NoteDetail>> getNotesInBoard(String boardName) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final pinSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .where('collection', isEqualTo: boardName)
        .orderBy('savedAt', descending: true)
        .get();

    final futures = pinSnapshot.docs.map((doc) async {
      try {
        return await getNoteById(doc['noteId']);
      } catch (_) {
        return null;
      }
    });

    final notes = await Future.wait(futures);
    return notes.whereType<NoteDetail>().toList();
  }

  Future<void> hapusPapan(String boardId, String boardName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();

    batch.delete(_db
        .collection('users')
        .doc(user.uid)
        .collection('boards')
        .doc(boardId));

    final pinsSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .where('collection', isEqualTo: boardName)
        .get();

    for (var doc in pinsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<bool> isLiked(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _db
        .collection('notes')
        .doc(noteId)
        .collection('likes')
        .doc(user.uid)
        .get();

    return doc.exists;
  }

  Future<void> toggleLike(String noteId, bool shouldLike) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login");

    final likeRef = _db
        .collection('notes')
        .doc(noteId)
        .collection('likes')
        .doc(user.uid);

    if (shouldLike) {
      await likeRef.set({
        'userId': user.uid,
        'likedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await likeRef.delete();
    }
  }

  Future<int> getLikeCount(String noteId) async {
    final snapshot = await _db
        .collection('notes')
        .doc(noteId)
        .collection('likes')
        .get();

    return snapshot.docs.length;
  }
}
