import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';

import '../services/catatan_service.dart';
import '../widgets/section_card.dart';
import '../widgets/pill_tag.dart';
import '../widgets/action_icon_button.dart';
import '../widgets/image_carousel.dart';
import '../widgets/publisher_card.dart';

import '../models/note_details.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;
  const NoteDetailPage({super.key, required this.noteId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage>
    with AutomaticKeepAliveClientMixin {

  // STATUS VARIABLES
  bool pinned = false;
  bool liked = false;
  bool _isDownloading = false; // Menandakan sedang proses download atau tidak

  OverlayEntry? _overlayEntry;

  late Future<NoteDetail> _noteFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _noteFuture = NotesService().getNoteById(widget.noteId);
  }

  @override
  void dispose() {
    _removeOverlayIfAny();
    super.dispose();
  }

  // ==========================================
  // LOGIKA OVERLAY (TOAST CUSTOM)
  // ==========================================
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 10),
                    Flexible(
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

  // ==========================================
  // LOGIKA DOWNLOAD GAMBAR (VERSI GAL)
  // ==========================================
  Future<void> _downloadImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) {
      _showTopOverlay("Tidak ada gambar untuk diunduh");
      return;
    }

    // 1. Cek Permission menggunakan Gal
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
        hasAccess = await Gal.hasAccess();
        if (!hasAccess) return; // Jika user tetap menolak, berhenti.
      }
    } catch (e) {
      debugPrint("Error checking permission: $e");
    }

    setState(() => _isDownloading = true);

    // Tampilkan Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    int successCount = 0;

    try {
      for (var url in imageUrls) {
        // 2. Ambil data bytes gambar dari URL
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          await Gal.putImageBytes(
            Uint8List.fromList(response.bodyBytes),
            name: "EduPin_Img_${DateTime.now().millisecondsSinceEpoch}",
          );
          successCount++;
        }
      }
    } catch (e) {
      debugPrint("Error downloading: $e");
    } finally {
      if (mounted) {
        Navigator.pop(context); // Tutup dialog loading
        setState(() => _isDownloading = false);

        if (successCount > 0) {
          _showTopOverlay("Berhasil menyimpan $successCount gambar ke galeri");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal mengunduh gambar.")),
          );
        }
      }
    }
  }
// ==========================================
  // BOTTOM SHEET DINAMIS (DATA REAL DARI DATABASE)
  // ==========================================
  void _showPinSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, 0.73],
              colors: [Color(0xFF4B9CFF), Color(0xFF2272FE)],
            ),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER ... (sama seperti sebelumnya)
              Stack(
                alignment: Alignment.center,
                children: [
                  const Text('Simpan di pin anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- BAGIAN PENTING: STREAM BUILDER ---
              StreamBuilder<QuerySnapshot>(
                stream: NotesService().streamKoleksi(), // Ambil daftar papan
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final boards = snapshot.data?.docs ?? [];

                  if (boards.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text("Belum ada koleksi. Buat baru yuk!",
                          style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                    );
                  }

                  // TAMPILKAN LIST PAPAN
                  return Column(
                    children: boards.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final namaPapan = data['name'] ?? 'Tanpa Nama'; // Ambil nama asli dari DB (misal: "belajar uts")

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            Navigator.pop(ctx); // Tutup sheet
                            try {
                              // --- BAGIAN KUNCI ---
                              // Simpan pakai variabel `namaPapan` (dinamis), JANGAN tulis manual "Materi UTS"
                              await NotesService().simpanKePin(widget.noteId, namaPapan);

                              setState(() => pinned = true);
                              _showTopOverlay('Berhasil disimpan ke "$namaPapan"');
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  // Gambar ikon folder sementara
                                  child: Container(
                                    width: 48, height: 48, color: Colors.white24,
                                    child: const Icon(Icons.folder, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(namaPapan, // Tampilkan nama papan
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
              // TOMBOL BUAT BARU ... (sama seperti sebelumnya)
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/pin_baru');
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.add, color: Color(0xFF2272FE), size: 30),
                    ),
                    const SizedBox(height: 12),
                    const Text('Buat koleksi baru', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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

  // ==========================================
  // BUILD UI UTAMA
  // ==========================================
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<NoteDetail>(
      future: _noteFuture,
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFEFF6FF),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Error State
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFEFF6FF),
            appBar: AppBar(
              backgroundColor: const Color(0xFFEFF6FF),
              elevation: 0,
              leading: BackButton(onPressed: () => context.pop()),
            ),
            body: Center(child: Text("Terjadi kesalahan: ${snapshot.error}")),
          );
        }

        // 3. Data Ready State
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));
        }

        final d = snapshot.data!;
        final size = MediaQuery.sizeOf(context);

        final pagePad = EdgeInsets.symmetric(
          horizontal: size.width * 0.06,
          vertical: 12,
        );

        // ---------- HEADER ----------
        final header = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          d.grade,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          d.subject,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );

        // ---------- ACTION BUTTONS ----------
        final actions = Row(
          children: [
            // TOMBOL PIN
            ActionIconButton(
              icon: Icons.push_pin_outlined,
              tooltip: pinned ? 'Lepas dari pin' : 'Simpan ke pin',
              toggled: pinned,
              onTap: () {
                setState(() => pinned = !pinned);
                if (pinned) _showPinSheet();
              },
            ),
            // TOMBOL DOWNLOAD (SUDAH DIPERBAIKI)
            ActionIconButton(
              icon: _isDownloading
                  ? Icons.hourglass_empty
                  : Icons.download_outlined,
              tooltip: 'Download',
              onTap: () {
                if (!_isDownloading) {
                  _downloadImages(d.imageAssets);
                }
              },
            ),
            // TOMBOL REPORT
            ActionIconButton(
              icon: Icons.flag_outlined,
              tooltip: 'Laporkan',
              onTap: () => context.push('/report', extra: d),
            ),
            const Spacer(),
            // TOMBOL LIKE
            ActionIconButton(
              icon: liked ? Icons.favorite : Icons.favorite_border,
              tooltip: 'Suka',
              toggled: liked,
              onTap: () => setState(() => liked = !liked),
            ),
          ],
        );

        // ---------- DESCRIPTION ----------
        final description = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(d.description),
            const SizedBox(height: 10),
            const Text('Tags',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: d.tags.map((t) => PillTag(t)).toList(),
            ),
          ],
        );

        // ---------- MAIN CARD ----------
        final mainCard = SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 12),
              ImageCarousel(assets: d.imageAssets),
              const SizedBox(height: 8),
              actions,
              const Divider(height: 24),
              description,
            ],
          ),
        );

        // ---------- PUBLISHER CARD ----------
        final publisherCard = GestureDetector(
          onTap: () {
            context.push('/profile_user', extra: d.publisher);
          },
          child: PublisherCard(p: d.publisher),
        );

        // ---------- SCAFFOLD RETURN ----------
        return Scaffold(
          backgroundColor: const Color(0xFFEFF6FF),
          appBar: AppBar(
            backgroundColor: const Color(0xFFEFF6FF),
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            leading: BackButton(
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: pagePad,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 700;

                  if (wide) {
                    return SingleChildScrollView(
                      clipBehavior: Clip.none,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: mainCard),
                          const SizedBox(width: 16),
                          Expanded(flex: 5, child: publisherCard),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    clipBehavior: Clip.none,
                    children: [
                      mainCard,
                      const SizedBox(height: 12),
                      publisherCard,
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}