import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const EduPinApp());

class EduPinApp extends StatelessWidget {
  const EduPinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduPin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7BFF)),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.w700),
          bodyMedium: TextStyle(height: 1.3),
        ),
      ),
      home: const SplashScreen(), // <- pastikan mulai dari Splash
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.delay = const Duration(milliseconds: 2200),
  });

  /// Bisa diubah saat testing biar ga nunggu lama.
  final Duration delay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  late final Image _logo =
  Image.asset('assets/logo/edupin_logo.png', filterQuality: FilterQuality.medium);

  @override
  void initState() {
    super.initState();

    // Preload logo supaya saat muncul tidak kedip.
    // ignore: discarded_futures
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await precacheImage(_logo.image, context);
    });

    _timer = Timer(widget.delay, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final shortest = size.shortestSide;
    final padding = shortest * 0.04;

    // batas responsif
    final maxLogoHeight = size.height * 0.38;
    final maxLogoWidth = size.width * 0.66;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: mq.platformBrightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: WillPopScope(
        // Cegah tombol back keluar saat splash.
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.98),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final spacing = constraints.maxHeight * 0.02;
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxLogoHeight,
                            maxWidth: maxLogoWidth,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: FittedBox(fit: BoxFit.contain, child: _logo),
                          ),
                        ),
                        SizedBox(height: spacing * 1.5),
                        Text(
                          'EduPin',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: spacing * 0.75),
                        Text(
                          'Platform Berbagi Catatan Pelajaran',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).size.shortestSide * 0.05;
    return Scaffold(
      appBar: AppBar(title: const Text('EduPin Home')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: const Text(
            'Halo! Ini layar setelah splash.\nSiap lanjut bangun fitur berikutnya. 🚀',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
