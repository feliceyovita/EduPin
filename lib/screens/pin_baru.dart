import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/catatan_service.dart'; // Import service untuk simpan ke database

class PinBaruScreen extends StatefulWidget {
  const PinBaruScreen({super.key});

  @override
  State<PinBaruScreen> createState() => _PinBaruScreenState();
}

class _PinBaruScreenState extends State<PinBaruScreen> {
  final _titleC = TextEditingController();
  bool _isFormValid = false;
  bool _isLoading = false; // Variabel untuk status loading

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
    _removeOverlayIfAny();
    super.dispose();
  }

  // ======================================================
  // FUNGSI SIMPAN KE DATABASE (SUDAH DIPERBAIKI)
  // ======================================================
  Future<void> _onSimpan() async {
    final title = _titleC.text.trim();
    if (title.isEmpty) return;

    // 1. Mulai Loading
    setState(() => _isLoading = true);

    try {
      // 2. Panggil Service Firebase
      await NotesService().buatPapanBaru(title);

      // 3. Jika Sukses, Tampilkan Overlay
      if (mounted) {
        _showTopOverlay('Koleksi "$title" berhasil dibuat');

        // Beri jeda 1.5 detik agar user sempat baca notifikasi, lalu kembali
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            context.pop(); // Kembali ke halaman sebelumnya
          }
        });
      }
    } catch (e) {
      // 4. Jika Gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuat papan: $e")),
        );
        setState(() => _isLoading = false); // Matikan loading biar bisa coba lagi
      }
    }
  }

  // ======================================================
  // LOGIKA OVERLAY (CUSTOM TOAST)
  // ======================================================
  void _removeOverlayIfAny() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

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

    overlay.insert(_overlayEntry!);
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
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF6FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text('Buat koleksi baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              // Logika Tampilan Tombol: Kalau loading tampilkan putaran, kalau tidak tampilkan icon save
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save, size: 18),
              label: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
              // Matikan tombol jika form tidak valid ATAU sedang loading
              onPressed: (_isFormValid && !_isLoading) ? _onSimpan : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
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
                    'assets/images/sample_note.jpeg', // Pastikan gambar ini ada di assets
                    width: 150,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Judul Input
              const Text(
                'Judul koleksi *',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleC,
                autofocus: true, // Keyboard langsung muncul
                enabled: !_isLoading, // Disable input saat loading
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