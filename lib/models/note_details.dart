import 'package:cloud_firestore/cloud_firestore.dart';

class Publisher {
  final String id;
  final String name;
  final String handle;
  final String institution;
  final String avatarAsset;

  const Publisher({
    required this.id,
    required this.name,
    required this.handle,
    required this.institution,
    required this.avatarAsset,
  });

  factory Publisher.fromMap(Map<String, dynamic> data) {
    return Publisher(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      handle: data['handle'] ?? '',
      institution: data['institution'] ?? '',
      avatarAsset: data['avatarAsset'] ?? '',
    );
  }
}


class NoteDetail {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String grade;
  final String school;
  final List<String> tags;
  final String imageUrl;
  final String authorId;
  final Publisher publisher;
  final List<String> imageAssets;
  final bool publikasi;
  final bool izinkanUnduh;



  NoteDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.grade,
    required this.school,
    required this.tags,
    required this.imageUrl,
    required this.authorId,
    required this.publisher,
    required this.imageAssets,
    required this.publikasi,
    required this.izinkanUnduh,

  });

  factory NoteDetail.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NoteDetail(
      id: doc.id,
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      subject: data["subject"] ?? "Umum",
      grade: data["grade"] ?? "",
      school: data["school"] ?? "",
      tags: List<String>.from(data["tags"] ?? []),
      imageUrl: data["imageUrl"] ?? "",
      authorId: data["authorId"] ?? "",
      publisher: Publisher.fromMap(data['publisher'] ?? {}),
      imageAssets: List<String>.from(data["imageAssets"] ?? []),
      publikasi: data['publikasi'] ?? true,
      izinkanUnduh: data['izinkanUnduh'] ?? true,
    );
  }
}

