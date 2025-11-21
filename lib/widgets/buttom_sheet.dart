import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//
// ------------- SHEET: SIMPAN DI PIN ANDA -----------------
//

void showPinSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;

      return Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.0, 0.73],
            colors: [
              Color(0xFF2272FE),
              Color(0xFF4B9CFF),
            ],
          ),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Simpan di pin anda',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Koleksi contoh
            InkWell(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disimpan ke "Materi UTS"')),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/sample_note.jpeg',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Materi UTS',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Button buat koleksi baru
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                context.push('/pin_baru');
              },
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.add, size: 30, color: Color(0xFF2272FE)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Buat koleksi baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}


//
// ------------- SHEET: TAMBAH CATATAN BARU -----------------
//

void showUploadSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;

      return Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2272FE),
              Color(0xFF4B9CFF),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Stack(
              alignment: Alignment.center,
              children: [
                const Text(
                  'Tambah Catatan Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            const Text(
              'Bagikan catatan anda dengan komunitas',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 32),

            // Tombol Mulai Unggah
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                context.push('/upload');
              },
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Image.asset(
                      'assets/images/unggah.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mulai Unggah',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}
