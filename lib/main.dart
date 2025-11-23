import 'package:flutter/material.dart';
import 'app/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';   // dari flutterfire configure

void main() async {
  // 1. Buat main async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Edupin',
      theme: ThemeData(fontFamily: 'AlbertSans', primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      locale: const Locale('id','ID'),
      supportedLocales: const [Locale('id','ID'), Locale('en','US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
