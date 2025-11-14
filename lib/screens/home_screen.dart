import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_navbar.dart';
import 'profile_screen.dart';

/// ===================
/// HALAMAN PLACEHOLDER
/// ===================

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman Beranda'));
  }
}

class CariScreen extends StatelessWidget {
  const CariScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman Cari'));
  }
}

class PinScreen extends StatelessWidget {
  const PinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman Pin'));
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
  int _currentIndex = 0;

  // Urutan halaman sesuai bottom nav:
  // 0: Beranda, 1: Cari, 2: (Unggah → bottom sheet), 3: Pin, 4: Profil
  final List<Widget> _pages = const [
    BerandaScreen(),
    CariScreen(),
    SizedBox.shrink(), // index 2 (Unggah) tidak dipakai sebagai page
    PinScreen(),
    ProfileScreen(),
  ];

  void _onNavBarTap(int index) {
    if (index == 2) {
      _showUploadSheet();
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Wajib transparan agar rounded corner terlihat
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;

        return Container(
          width: double.infinity,
          // Dekorasi ini sudah benar
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            // Gradient linear ini sudah benar sesuai gambar Figma
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.20, 0.61],
              colors: [
                Color(0xFF009EF7),
                Color(0xFF2583FF),
              ],
            ),
          ),
          // Padding internal untuk konten,
          // kita tambahkan bottomInset agar konten tidak tertutup nav bar
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // baris judul + tombol X
              Row(
                children: [
                  const _CloseButton(),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Tambah Catatan Baru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Bagikan catatan Anda dengan komunitas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 15),

              InkWell(
                onTap: () {
                  Navigator.pop(ctx);       // tutup sheet dulu
                  context.push('/upload');  // lalu ke halaman form
                },
                // Menyesuaikan bentuk ripple effect agar bulat
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/Upload.jpg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx); // tutup sheet dulu
                    context.push('/upload'); // lalu ke halaman form
                  },
                  child: const Text(
                    'Mulai Unggah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700, // Opsional
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    );
  }
}
