import 'package:flutter/material.dart';
import 'app/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(); // 🔹 panggil router.dart

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EduPin',
      routerConfig: router, // 🔹 inilah yang ganti "home: SplashScreen"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "AlbertSans",
      ),
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
    );
  }
}
