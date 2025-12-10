import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/supabase_storage_service.dart';
import '../services/catatan_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesProvider extends ChangeNotifier {
  final storage = SupabaseStorageService();
  final notesService = NotesService();

  bool isLoading = false;

  Future<Map<String, dynamic>> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    return snap.data() ?? {};
  }

  Future<String> uploadNote({
    required List<File> imageAssets,
    required String title,
    required String description,
    required String subject,
    required String grade,
    required String school,
    required List<String> tags,
    required bool publikasi,
    required bool izinkanUnduh,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final userData = await _getUserData();

      final publisherData = {
        "name": userData["nama"] ?? "",
        "handle": userData["username"] ?? "",
        "institution": userData["sekolah"] ?? "",
        "avatarAsset": userData["foto"] ?? "",
      };

      List<String> uploadedUrls = [];
      for (var img in imageAssets) {
        final url = await storage.uploadImage(img);
        uploadedUrls.add(url);
      }

      final docRef = await notesService.createNote({
        "title": title,
        "description": description,
        "subject": subject,
        "grade": grade,
        "school": school,
        "tags": tags,
        "publikasi": publikasi,
        "izinkanUnduh": izinkanUnduh,
        "imageUrl": uploadedUrls.isNotEmpty ? uploadedUrls.first : "",
        "imageAssets": uploadedUrls,
        "createdAt": FieldValue.serverTimestamp(),
        "authorId": FirebaseAuth.instance.currentUser!.uid,
        "publisher": publisherData,
      });

      return docRef.id;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String description,
    required String subject,
    required String grade,
    required String school,
    required List<String> tags,
    required bool publikasi,
    required bool izinkanUnduh,
    required List<File> imageAssets,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      List<String> uploadedUrls = [];
      for (var img in imageAssets) {
        final url = await storage.uploadImage(img);
        uploadedUrls.add(url);
      }

      final updateData = {
        "title": title,
        "description": description,
        "subject": subject,
        "grade": grade,
        "school": school,
        "tags": tags,
        "publikasi": publikasi,
        "izinkanUnduh": izinkanUnduh,
        "updatedAt": FieldValue.serverTimestamp(),
      };

      if (uploadedUrls.isNotEmpty) {
        updateData["imageAssets"] = uploadedUrls;
        updateData["imageUrl"] = uploadedUrls.first;
      }

      await notesService.updateNote(noteId, updateData);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
