import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/detail_catatan.dart';
import '../screens/report_note_screen.dart';
import '../models/note_details.dart';
import '../screens/upload_catatan.dart';

GoRouter buildRouter() {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/home',
    routes: [
      // ➜ HOME route WAJIB ADA
      GoRoute(
          path: '/upload',
          builder: (_, __) => const UploadCatatanScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/_debug/detail',
        builder: (context, state) {
          final dummy = NoteDetail(
            id: 'd1',
            title: 'Rumus Integral dan Diferensial',
            subject: 'Matematika',
            grade: 'Kelas 12',
            tags: ['kalkulus','Integral','ParsialII','MTKez'],
            description: 'Catatan lengkap…',
            imageAssets: ['assets/images/sample_note.jpeg'],
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

      GoRoute(
        path: '/report',
        builder: (context, state) =>
            ReportNoteScreen(note: state.extra as NoteDetail),
      ),
    ],
  );
}

