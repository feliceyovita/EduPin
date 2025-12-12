import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import '../screens/papan_screen.dart';
import '../screens/notifikasi_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/edit_catatan_screen.dart';
import '../screens/pin_baru.dart';
import '../screens/upload_catatan.dart';
import '../screens/detail_catatan.dart';
import '../screens/report_note_screen.dart';
import '../screens/profile_user.dart';
import '../screens/papan_detail_screen.dart';
import '../models/note_details.dart';
import '../widgets/app_navbar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash_screen',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final loggingIn = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/forgot_password';
    if (user == null && !loggingIn) return '/login';
    if (user != null && loggingIn) return '/home';
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: AppNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              if (index == 2) {
                context.push('/upload');
                return;
              }
              navigationShell.goBranch(index);
            },
          ),
        );
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final type = state.uri.queryParameters['type'];
              final value = state.uri.queryParameters['value'];
              return HomeScreen(filterType: type, filterValue: value);
            },
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/papan', builder: (_, __) => const PapanScreen()),
          GoRoute(
            path: '/papan_detail',
            builder: (context, state) {
              return PapanDetailScreen(boardName: state.extra as String);
            },
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/dummy_upload_branch', builder: (_, __) => const SizedBox.shrink()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/notifikasi', builder: (_, __) => const NotifikasiScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ]),
      ],
    ),
    GoRoute(path: '/splash_screen', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/forgot_password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(
      path: '/edit_catatan',
      builder: (context, state) => EditCatatanScreen(note: state.extra as NoteDetail),
    ),
    GoRoute(path: '/pin_baru', builder: (_, __) => const PinBaruScreen()),
    GoRoute(path: '/upload', builder: (_, __) => const UploadCatatanScreen()),
    GoRoute(
      path: '/detail_catatan',
      builder: (context, state) => NoteDetailPage(noteId: state.extra as String),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => ReportNoteScreen(note: state.extra as NoteDetail),
    ),
    GoRoute(
      path: '/profile_user',
      builder: (context, state) => ProfileUserScreen(authorId: state.extra as String),
    ),
  ],
);
