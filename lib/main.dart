import 'package:edupin/provider/catatan_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';      // dari flutterfire configure
import 'app/router.dart';            // konfigurasi GoRouter
import '../provider/auth_provider.dart'; // provider untuk autentikasi

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://kiriybnogbzcjlrzdzvs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtpcml5Ym5vZ2J6Y2pscnpkenZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxODAzNzIsImV4cCI6MjA3OTc1NjM3Mn0.lBMytpsZmkHb8UKYkQSS9SNYRqf1pgEqfbfbleSBdBU',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Edupin',
      theme: ThemeData(
        fontFamily: 'AlbertSans',
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router, // dari file app/router.dart
    );
  }
}
