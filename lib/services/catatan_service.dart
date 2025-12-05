import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note_details.dart';

class NotesService {
  // Instance Firestore dan Auth
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // BAGIAN 1: CRUD CATATAN (NOTES)
  // ==========================================

  // 1. TAMBAH CATATAN BARU
  Future<void> createNote(Map<String, dynamic> data) async {
    if (!data.containsKey('createdAt')) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await _db.collection("notes").add(data);
  }

  // 2. STREAM DAFTAR SEMUA CATATAN (HOME)
  Stream<List<NoteDetail>> streamNotes() {
    return _db
        .collection("notes")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => NoteDetail.fromFirestore(d)).toList());
  }

  // 3. AMBIL 1 CATATAN BERDASARKAN ID (DETAIL)
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

  // ==========================================
  // BAGIAN 2: FITUR PIN / SIMPAN (USER SPECIFIC)
  // ==========================================

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


  // 6. CEK APAKAH CATATAN SUDAH DIPIN?
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

  // ==========================================
  // BAGIAN 3: KOLEKSI / PAPAN (BOARDS)
  // ==========================================

  // 7. AMBIL DAFTAR KOLEKSI USER
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

  // 8. BUAT KOLEKSI BARU
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

  // 9. AMBIL NOTES DI DALAM PAPAN TERTENTU
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
  } // <--- PENUTUP getNotesInBoard HARUSNYA DI SINI

  // ==========================================
  // 10. HAPUS PAPAN & ISI PIN-NYA
  // ==========================================
  // FUNGSI INI HARUS DI LUAR getNotesInBoard
  Future<void> hapusPapan(String boardId, String boardName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();

    // 1. Hapus Papan
    final boardRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('boards')
        .doc(boardId);

    batch.delete(boardRef);

    // 2. Cari semua Pin terkait, lalu hapus
    final pinsSnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .where('collection', isEqualTo: boardName)
        .get();

    for (var doc in pinsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 3. Jalankan batch
    await batch.commit();
  }
}