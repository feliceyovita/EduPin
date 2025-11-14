import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import '../widgets/section_card.dart'; // Tidak dipakai

class PinBaruScreen extends StatefulWidget {
  const PinBaruScreen({super.key});

  @override
  State<PinBaruScreen> createState() => _PinBaruScreenState();
}

class _PinBaruScreenState extends State<PinBaruScreen> {
  final _titleC = TextEditingController();
  bool _isFormValid = false;

  // 1. Tambahkan variabel ini untuk melacak overlay
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _titleC.addListener(() {
      setState(() {
        _isFormValid = _titleC.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _titleC.dispose();
    _removeOverlayIfAny(); // Hapus overlay jika pindah halaman
    super.dispose();
  }

  void _onSimpan() {
    final title = _titleC.text.trim();

    // ======================================================
    // 2. PANGGIL FUNGSI OVERLAY DI SINI
    // ======================================================
    _showTopOverlay('Koleksi "$title" berhasil dibuat');

    // Beri jeda agar user sempat baca, baru kembali
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.pop(); // Kembali ke halaman detail
      }
    });

    // Hapus SnackBar lama jika Anda masih menggunakannya
    // ScaffoldMessenger.of(context).showSnackBar(...);
  }

  // ======================================================
  // 3. FUNGSI HELPER UNTUK MENGHAPUS OVERLAY
  // ======================================================
  void _removeOverlayIfAny() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ======================================================
  // 4. KODE OVERLAY ANDA (Sudah saya lengkapi)
  // ======================================================
  void _showTopOverlay(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    _removeOverlayIfAny();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final topPadding = MediaQuery.of(context).viewPadding.top + 8.0;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: topPadding,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: AnimatedOpacity(
              // Atur opacity ke 1.0 (Anda bisa animasikan ini nanti)
              opacity: 1.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // ======================================================
    // 5. PERINTAH UNTUK MENAMPILKAN DAN MENGHILANGKAN
    // ======================================================
    overlay.insert(_overlayEntry!); // Tampilkan overlay ke layar

    // Hilangkan otomatis setelah 'duration'
    Future.delayed(duration, _removeOverlayIfAny);
  }

  @override
  Widget build(BuildContext context) {
    // Definisi border untuk textfield
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF), // Warna background halaman
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF6FF), // Samakan warna AppBar
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false, // Judul di kiri
        title: const Text('Buat koleksi baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Simpan'),
              onPressed: _isFormValid ? _onSimpan : null, // Dinamis
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Warna biru
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar placeholder
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/sample_note.jpeg', // Ganti ke thumbnail
                    width: 150,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Judul
              const Text(
                'Judul koleksi *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleC,
                decoration: InputDecoration(
                  hintText: 'Contoh: Kriptografi',
                  prefixIcon: const Icon(
                    Icons.file_copy_outlined,
                    color: Color(0xFF2563EB),
                  ),
                  border: inputBorder,
                  enabledBorder: inputBorder,
                  focusedBorder: focusBorder,
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}