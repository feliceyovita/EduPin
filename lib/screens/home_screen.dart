import 'package:flutter/material.dart';
import 'package:edupin/widgets/app_navbar.dart'; // Sesuaikan path jika perlu
import 'package:edupin/screens/profile_screen.dart'; // Import ProfileScreen

// Placeholder untuk halaman lain agar tidak error
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Halaman Beranda')));
  }
}

class CariScreen extends StatelessWidget {
  const CariScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Halaman Cari')));
  }
}

class UnggahScreen extends StatelessWidget {
  const UnggahScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Halaman Unggah')));
  }
}

class PinScreen extends StatelessWidget {
  const PinScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Halaman Pin')));
  }
}


// --- Widget Utama untuk Navigasi ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State untuk menyimpan index halaman yang aktif
  int _currentIndex = 0;

  // Daftar semua halaman yang akan ditampilkan sesuai urutan navbar
  final List<Widget> _pages = [
    const BerandaScreen(),    // Index 0
    const CariScreen(),       // Index 1
    const UnggahScreen(),     // Index 2
    const PinScreen(),        // Index 3
    const ProfileScreen(),    // Index 4 <-- Ini dia halaman profilmu
  ];

  // Fungsi yang akan dipanggil saat item navbar ditekan
  void _onNavBarTap(int index) {
    // Jika menekan tombol 'Unggah' (index 2), mungkin ingin menampilkan dialog/modal
    // dan tidak mengubah halaman. Ini contoh saja.
    if (index == 2) {
      // Tampilkan modal atau navigasi ke halaman khusus unggah
      print("Tombol unggah ditekan!");
      // Untuk sekarang, kita tetap pindah halaman
      setState(() {
        _currentIndex = index;
      });
    } else {
      // Ubah state untuk membangun ulang UI dengan halaman yang baru
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan halaman dari daftar `_pages` sesuai `_currentIndex`
      body: _pages[_currentIndex],
      // Gunakan AppNavBar di sini
      bottomNavigationBar: AppNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap, // Sambungkan fungsi tap-nya ke sini
      ),
    );
  }
}
