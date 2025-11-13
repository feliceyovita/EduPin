import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:edupin/widgets/app_navbar.dart';
import 'package:edupin/screens/profile_screen.dart';

/// ===================
/// HALAMAN PLACEHOLDER
/// ===================

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Halaman Beranda'),
    );
  }
}

class CariScreen extends StatelessWidget {
  const CariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Halaman Cari'),
    );
  }
}

class PinScreen extends StatelessWidget {
  const PinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Halaman Pin'),
    );
  }
}

/// ===================
/// HOME DENGAN NAVBAR
/// ===================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // index tab aktif
  int _currentIndex = 0;

  // urutan halaman sesuai urutan item navbar:
  // 0: Beranda, 1: Cari, 2: (Unggah -> pakai GoRouter), 3: Pin, 4: Profil
  final List<Widget> _pages = const [
    BerandaScreen(),          // index 0
    CariScreen(),             // index 1
    SizedBox.shrink(),        // index 2: Unggah (tidak dipakai sebagai body)
    PinScreen(),              // index 3
    ProfileScreen(),          // index 4
  ];

  void _onNavBarTap(int index) {
    if (index == 2) {
      // ✅ Tombol tambah → dorong halaman upload di atas halaman sekarang
      // sehingga bisa kembali dengan context.pop()
      context.push('/upload');
      return;
    }

    // Tab lain cukup mengganti konten di HomeScreen
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
