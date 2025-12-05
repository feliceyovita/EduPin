import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note_details.dart';

class NotesService {
  // Instance Firestore dan Auth
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. TAMBAH CATATAN BARU
  Future<void> createNote(Map<String, dynamic> data) async {
    if (!data.containsKey('createdAt')) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection("notes").add(data);
  }

  // 2. STREAM SEMUA CATATAN UNTUK BERANDA
  Stream<List<NoteDetail>> streamNotes() {
    return _db
        .collection("notes")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => NoteDetail.fromFirestore(d)).toList());
  }

  // 3. AMBIL 1 CATATAN BERDASARKAN ID
  Future<NoteDetail> getNoteById(String noteId) async {
    final doc = await _db.collection("notes").doc(noteId).get();

    if (!doc.exists) {
      throw Exception("Note dengan ID $noteId tidak ditemukan");
    }

    return NoteDetail.fromFirestore(doc);
  }

  // 4. UPDATE CATATAN
  Future<void> updateNote(String noteId, Map<String, dynamic> data) async {
    final docRef = _db.collection("notes").doc(noteId);
    await docRef.update(data);
  }

  // 5. SIMPAN CATATAN KE PIN USER
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

  // 6. CEK APAKAH SUDAH DIPIN
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

  Stream<QuerySnapshot> streamKoleksi() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

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
  // untuk simpan ke pin (sudah ada)
  Future<void> pinNote(String noteId, {String? namaKoleksi}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login");

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .doc(noteId)
        .set({
      'noteId': noteId,
      'collection': namaKoleksi ?? 'default',
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

// untuk hapus dari pin (belum ada)
  Future<void> unpinNote(String noteId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login");

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .doc(noteId)
        .delete();
  }


  Future<List<NoteDetail>> getNotesInBoard(String boardName) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final pinSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .where('collection', isEqualTo: boardName)
       .get();

    List<NoteDetail> results = [];

    final futures = pinSnapshot.docs.map((doc) async {
      final noteId = doc['noteId'];
      try {
        final note = await getNoteById(noteId);
        return note;
      } catch (e) {
        return null;
      }
    });

    final notes = await Future.wait(futures);

    for (var n in notes) {
      if (n != null) results.add(n);
    }

    return results;
  }

  Future<void> hapusPapan(String boardId, String boardName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();

    final boardRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('boards')
        .doc(boardId);

    batch.delete(boardRef);

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
}
