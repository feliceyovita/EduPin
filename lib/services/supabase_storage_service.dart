import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final supabase = Supabase.instance.client;

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

}
