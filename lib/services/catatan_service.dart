import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_details.dart';

class NotesService {
  final _db = FirebaseFirestore.instance;

  Future<void> createNote(Map<String, dynamic> data) async {
    await _db.collection("notes").add(data);
  }

  Stream<List<NoteDetail>> streamNotes() {
    return _db.collection("notes")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => NoteDetail.fromFirestore(d)).toList()
    );
  }


  Future<NoteDetail> getNoteById(String noteId) async {
    final doc = await _db.collection("notes").doc(noteId).get();

    if (!doc.exists) {
      throw Exception("Note dengan ID $noteId tidak ditemukan");
    }

    return NoteDetail.fromFirestore(doc);
  }
  Future<void> updateNote(String noteId, Map<String, dynamic> data) async {
    final docRef = _db.collection("notes").doc(noteId);
    await docRef.update(data);
  }


}
