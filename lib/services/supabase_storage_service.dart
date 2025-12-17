import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final supabase = Supabase.instance.client;
  static const _bucket = 'image_catatan';

  Future<String> uploadImage(File image) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final bytes = await image.readAsBytes();
    await supabase.storage
        .from('image_catatan')
        .uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg'),
    );

    return supabase.storage.from('image_catatan').getPublicUrl(fileName);
  }
  Future<void> deleteImageByUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final bucketIndex = uri.pathSegments.indexOf(_bucket);
    if (bucketIndex == -1) return;
    final objectPath =
    uri.pathSegments.sublist(bucketIndex + 1).join('/');
    if (objectPath.isEmpty) return;
    await supabase.storage
        .from(_bucket)
        .remove([objectPath]);
  }

}
