import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/catatan_service.dart';
import '../widgets/section_card.dart';
import '../widgets/pill_tag.dart';
import '../widgets/action_icon_button.dart';
import '../widgets/image_carousel.dart';
import '../widgets/publisher_card.dart';
import '../models/note_details.dart';
import '../services/notification_service.dart';

import '../widgets/save_to_pin_sheet.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;
  const NoteDetailPage({super.key, required this.noteId});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage>
    with AutomaticKeepAliveClientMixin {

  bool pinned = false;
  bool liked = false;
  bool _isDownloading = false;
  OverlayEntry? _overlayEntry;
  late Future<NoteDetail> _noteFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _noteFuture = NotesService().getNoteById(widget.noteId);
    _checkIfPinned();
    _checkIfLiked();
  }

  void _checkIfPinned() async {
    bool status = await NotesService().isPinned(widget.noteId);
    if (mounted) setState(() => pinned = status);
  }

  void _checkIfLiked() async {
    bool status = await NotesService().isLiked(widget.noteId);
    if (mounted) setState(() => liked = status);
  }

  @override
  void dispose() {
    _removeOverlayIfAny();
    super.dispose();
  }

  // --- LOGIKA OVERLAY ---
  void _removeOverlayIfAny() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showTopOverlay(String message, {Duration duration = const Duration(seconds: 2)}) {
    _removeOverlayIfAny();
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final topPadding = MediaQuery.of(context).viewPadding.top + 8.0;

    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        top: topPadding, left: 16, right: 16,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0, duration: const Duration(milliseconds: 250),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Flexible(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
        ),
      );
    });
    overlay.insert(_overlayEntry!);
    Future.delayed(duration, _removeOverlayIfAny);
  }

  // ==========================================
  // LOGIKA DOWNLOAD GAMBAR (VERSI GAL - LENGKAP)
  // ==========================================
  Future<void> _downloadImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) {
      _showTopOverlay("Tidak ada gambar untuk diunduh");
      return;
    }

    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
        hasAccess = await Gal.hasAccess();
        if (!hasAccess) return;
      }
    } catch (e) {
      debugPrint("Error checking permission: $e");
    }

    setState(() => _isDownloading = true);

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
        Navigator.pop(context);
        setState(() => _isDownloading = false);

        if (successCount > 0) {
          _showTopOverlay("Berhasil menyimpan $successCount gambar ke Galeri");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal mengunduh gambar.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<NoteDetail>(
      future: _noteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              backgroundColor: Color(0xFFEFF6FF),
              body: Center(child: CircularProgressIndicator())
          );
        }
        if (snapshot.hasError) return const Scaffold(body: Center(child: Text("Error")));
        if (!snapshot.hasData) return const Scaffold(body: Center(child: Text("Data tidak ada")));

        final d = snapshot.data!;
        final pagePad = EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.06, vertical: 12);

        // Header Section
        final header = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFEFF3FF), borderRadius: BorderRadius.circular(10)),
                  child: Text(d.grade, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  context.go('/home?type=category&value=${d.subject}');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFE5F2FF), borderRadius: BorderRadius.circular(10)),
                  child: Text(d.subject, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ])
          ]))
        ]);

        // Action Buttons
        final actions = Row(
          children: [
            // --- TOMBOL PIN ---
            ActionIconButton(
              icon: pinned ? Icons.push_pin : Icons.push_pin_outlined,
              tooltip: 'Simpan ke pin',
              toggled: pinned,
              onTap: () async {
                if (!pinned) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SaveToPinSheet(
                      noteId: widget.noteId,
                      onSuccess: (namaPapan) async {
                        await NotesService().simpanKePin(widget.noteId, namaPapan);
                        setState(() => pinned = true);
                        _showTopOverlay('Berhasil disimpan ke "$namaPapan"');
                      },
                    ),
                  );
                } else {
                  await NotesService().hapusPin(widget.noteId);
                  setState(() => pinned = false);
                  _showTopOverlay('Catatan di-unpin');
                }
              },
            ),
            // --- TOMBOL DOWNLOAD (ENABLE/DISABLE) ---
            ActionIconButton(
              icon: _isDownloading ? Icons.hourglass_empty : Icons.download_outlined,
              tooltip: d.izinkanUnduh ? 'Download' : 'Download tidak diizinkan',
              disabled: !d.izinkanUnduh || _isDownloading,
              onTap: () async {
                if (!d.izinkanUnduh) return;
                setState(() => _isDownloading = true);
                await _downloadImages(d.imageAssets);
                setState(() => _isDownloading = false);
              },
            ),
            // --- TOMBOL LAPOR ---
            ActionIconButton(
              icon: Icons.flag_outlined,
              tooltip: 'Laporkan',
              onTap: () => context.push('/report', extra: d),
            ),
            const Spacer(),
            // --- TOMBOL LIKE ---
            ActionIconButton(
              icon: liked ? Icons.favorite : Icons.favorite_border,
              tooltip: 'Suka',
              toggled: liked,
              onTap: () async {
                // 1. Update Tampilan
                setState(() => liked = !liked);

                // 2. Update Database
                await NotesService().toggleLike(widget.noteId, liked);

                // 3. KIRIM NOTIFIKASI
                final currentUser = FirebaseAuth.instance.currentUser;

                if (liked && currentUser != null && currentUser.uid != d.authorId) {

                  await NotificationService().addNotification(
                    targetUserId: d.authorId,
                    message: 'menyukai pin Anda: "${d.title}"',
                    type: 'like',
                    noteId: widget.noteId,
                    actorId: currentUser.uid,
                  );
                }
              },
            ),
          ],
        );

        final description = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(d.description),
          const SizedBox(height: 10),
          const Text('Tags', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: d.tags.map((t) => GestureDetector(onTap: () {context.go('/home?type=tag&value=$t');}, child: PillTag(t),)).toList(),
          ),
        ]);

        final mainCard = SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          header, const SizedBox(height: 12),
          ImageCarousel(assets: d.imageAssets), const SizedBox(height: 8),
          actions, const Divider(height: 24),
          description,
        ]));

        final publisherCard = GestureDetector(
          onTap: () => context.push('/profile_user', extra: d.authorId),
          child: PublisherCard(
            authorId: d.authorId,
          ),
        );



        return Scaffold(
          backgroundColor: const Color(0xFFEFF6FF),
          appBar: AppBar(
              backgroundColor: const Color(0xFFEFF6FF),
              elevation: 0,
              leading: BackButton(onPressed: () => Navigator.of(context).maybePop())
          ),
          body: SafeArea(
            child: Padding(
              padding: pagePad,
              child: ListView(
                children: [mainCard, const SizedBox(height: 12), publisherCard],
              ),
            ),
          ),
        );
      },
    );
  }
}
