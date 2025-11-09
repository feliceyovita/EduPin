class Publisher {
  final String name;
  final String handle;
  final String institution;
  final String avatarAsset; // pakai asset dulu
  const Publisher({
    required this.name,
    required this.handle,
    required this.institution,
    required this.avatarAsset,
  });
}

class NoteDetail {
  final String id;
  final String title;
  final String subject;     // Contoh: "Matematika"
  final String grade;       // Contoh: "Kelas 12"
  final List<String> tags;  // #kalkulus, #Integral, ...
  final String description;
  final List<String> imageAssets; // > 1 gambar → carousel
  final Publisher publisher;

  const NoteDetail({
    required this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.tags,
    required this.description,
    required this.imageAssets,
    required this.publisher,
  });
}
