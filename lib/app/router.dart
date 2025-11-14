import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/detail_catatan.dart';
import '../screens/report_note_screen.dart';
import '../models/note_details.dart';
import '../screens/upload_catatan.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/edit_catatan_screen.dart';
import '../screens/pin_baru.dart';

GoRouter buildRouter() {
  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/detail',
    routes: [
      GoRoute(
        path: '/edit_catatan',
        builder: (context, state) => const EditCatatanScreen(),
      ),
      GoRoute(
        path: '/pin_baru',
        builder: (context, state) => const PinBaruScreen(),
      ),
      GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen()),
      GoRoute(
          path: '/forgot_password',
          builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
          path: '/upload',
          builder: (_, __) => const UploadCatatanScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ⬇️ route detail yang dipakai sebagai initial
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final dummy = NoteDetail(
            id: 'd1',
            title: 'Rumus Integral dan Diferensial',
            subject: 'Matematika',
            grade: 'Kelas 12',
            tags: ['kalkulus', 'Integral', 'ParsialII', 'MTKez'],
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