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
      // tombol tambah → buka bottom sheet
      _showUploadBottomSheet();
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showUploadBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB), // biru seperti desain
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Baris atas: tombol X + judul + subjudul
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // Icon close di kiri
                    _CloseButton(),
                    SizedBox(width: 8),
                    Expanded(
                      child: _UploadHeaderText(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon besar di tengah
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      size: 32,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol "Mulai Unggah"
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);      // tutup bottom sheet
                      context.go('/upload');   // pindah ke halaman form upload
                    },
                    child: const Text('Mulai Unggah'),
                  ),
                ),
              ],
            ),
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

/// Widget kecil biar kode header lebih rapi

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

class _UploadHeaderText extends StatelessWidget {
  const _UploadHeaderText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unggah Catatan Baru',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Bagikan catatan anda dengan komunitas',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
