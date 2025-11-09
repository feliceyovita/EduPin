import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/detail_catatan.dart';
import '../models/note_details.dart';

GoRouter buildRouter() {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,

    // 🟣 sementara: langsung ke halaman detail
    initialLocation: '/_debug/detail',

    routes: [
      GoRoute(
        path: '/_debug/detail',
        builder: (context, state) {
          final dummy = NoteDetail(
            id: 'd1',
            title: 'Rumus Integral dan Diferensial',
            subject: 'Matematika',
            grade: 'Kelas 12',
            tags: ['kalkulus', 'Integral', 'ParsialII', 'MTKez'],
            description:
            'Catatan lengkap tentang integral parsial meliputi rumus dasar, langkah-langkah penyelesaian, dan contoh soal beserta pembahasan. Cocok untuk siswa SMA maupun mahasiswa tingkat awal.',
            imageAssets: [
              'assets/images/sample_note.jpeg',
              'assets/images/sample_note.jpeg',
              'assets/images/sample_note.jpeg',
            ],
            publisher: const Publisher(
              name: 'Just Kidding Rowling',
              handle: '@jkrowling',
              institution: 'Universitas Indonesia',
              avatarAsset: 'assets/images/sample_note.jpeg',
            ),
          );
          return NoteDetailPage(data: dummy);
        },
      ),
    ],
  );
}
