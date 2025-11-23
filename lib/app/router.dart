import 'package:edupin/screens/notifikasi_screen.dart';
import 'package:edupin/screens/profile_screen.dart';
import 'package:edupin/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/detail_catatan.dart';
import '../screens/report_note_screen.dart';
import '../screens/profile_user.dart';
import '../models/note_details.dart';
import '../screens/upload_catatan.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/edit_catatan_screen.dart';
import '../screens/pin_baru.dart';
import '../widgets/app_navbar.dart';

int _getIndex(String location) {
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/papan')) return 1;
  if (location.startsWith('/unggah')) return 2;
  if (location.startsWith('/notifikasi')) return 3;
  if (location.startsWith('/profile')) return 4;
  return 0;
}

void _onTap(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go('/home');
      break;
    case 1:
      context.go('/papan');
      break;
    case 2:
      context.push('/upload');
      break;
    case 3:
      context.go('/notifikasi');
      break;
    case 4:
      context.go('/profile');
      break;
  }
}

final GoRouter router = GoRouter(
  navigatorKey: GlobalKey<NavigatorState>(),
  initialLocation: '/splash_screen',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: AppNavBar(
            currentIndex: _getIndex(state.uri.toString()),
            onTap: (i) => _onTap(context, i),
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/papan',
          builder: (context, state) => const Placeholder(),
        ),
        GoRoute(
          path: '/notifikasi',
          builder: (context, state) => const NotifikasiScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    GoRoute(
      path: '/splash_screen',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/edit_catatan',
      builder: (context, state) => const EditCatatanScreen(),
    ),
    GoRoute(
      path: '/pin_baru',
      builder: (context, state) => const PinBaruScreen(),
    ),
    GoRoute(
      path: '/upload',
      builder: (context, state) => const UploadCatatanScreen(),
    ),
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
    GoRoute(
      path: '/profile_user',
      builder: (context, state) {
        final publisherData = state.extra as Publisher;

        return ProfileUserScreen(publisher: publisherData);
      },
    ),
  ],
);