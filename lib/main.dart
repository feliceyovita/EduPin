import 'package:flutter/material.dart';
import 'app/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
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