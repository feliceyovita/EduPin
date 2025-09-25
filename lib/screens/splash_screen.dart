import 'package:flutter/material.dart';
import 'package:edupin/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>

    with TickerProviderStateMixin {

  late AnimationController _textController;



  @override
  void initState() {
    super.initState();

    // Delay 3 detik → pindah ke LoginPage
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }



  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hapus backgroundColor dari Scaffold
      body: Container(
        // Gunakan Container untuk latar belakang gradien
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
                  width: 200, // bisa disesuaikan biar proporsional
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "EduPin",
                style: TextStyle(
                  fontFamily: "AlbertSans", // pastikan sudah di-setup
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 6),
              Text(
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