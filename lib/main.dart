import 'package:flutter/material.dart';
import 'package:edupin/screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- PENTING

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edupin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "AlbertSans",
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,

      // --- INI ADALAH PENAMBAHAN PENTING ---
      locale: const Locale('id', 'ID'), // Set locale default ke Indonesia
      supportedLocales: const [
        Locale('id', 'ID'), // Dukungan untuk Indonesia
        Locale('en', 'US'), // (Opsional) Dukungan untuk English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // --- AKHIR PENAMBAHAN ---
    );
  }
}