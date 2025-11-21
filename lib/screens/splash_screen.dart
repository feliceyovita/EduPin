import 'package:edupin/screens/login_screen.dart';
import 'package:flutter/material.dart';
// 1. Ganti import dari login_screen ke home_screen
import 'package:edupin/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// 2. TickerProviderStateMixin tidak lagi diperlukan karena animasinya dihapus
class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      context.go('/login');
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 222, 229, 233),
              Color.fromARGB(255, 232, 241, 245),
              Color.fromARGB(255, 193, 207, 213),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: "app_logo",
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 200,
                    height: 200,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "EduPin",
                  style: TextStyle(
                    fontFamily: "AlbertSans",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Platform Berbagi Catatan Pelajaran",
                  style: TextStyle(
                    fontFamily: "AlbertSans",
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}

