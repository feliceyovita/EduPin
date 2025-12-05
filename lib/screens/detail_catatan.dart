import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    _checkLikeStatus();
  }

  void _checkIfPinned() async {
    bool status = await NotesService().isPinned(widget.noteId);
    if (mounted) setState(() => pinned = status);
  }

  Future<void> _checkLikeStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('notes').doc(widget.noteId).get();
      if (doc.exists && doc.data() != null) {
        List likesArr = doc.data()!['likes'] ?? [];
        if (mounted) setState(() => liked = likesArr.contains(user.uid));
      }
    } catch (e) {
      debugPrint("Error check like: $e");
    }
  }

  Future<void> _toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showTopOverlay("Silakan login dulu");
      return;
    }
    setState(() => liked = !liked);
    try {
      final ref = FirebaseFirestore.instance.collection('notes').doc(widget.noteId);
      if (liked) {
        await ref.update({'likes': FieldValue.arrayUnion([user.uid])});
      } else {
        await ref.update({'likes': FieldValue.arrayRemove([user.uid])});
      }
    } catch (e) {
      setState(() => liked = !liked);
    }
  }

  @override
  void dispose() {
    _removeOverlayIfAny();
    super.dispose();
  }

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

  Future<void> _downloadImages(List<String> imageUrls) async {
    if (imageUrls.isEmpty) {
      _showTopOverlay("Tidak ada gambar");
      return;
    }
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
        if (!await Gal.hasAccess()) return;
      }
    } catch (e) {
      debugPrint("Perm error: $e");
    }

    setState(() => _isDownloading = true);
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)));

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
      debugPrint("DL error: $e");
    } finally {
      if (mounted) {
        Navigator.pop(context);
        setState(() => _isDownloading = false);
        if (successCount > 0) _showTopOverlay("Berhasil menyimpan $successCount gambar");
        else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal mengunduh.")));
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
          return const Scaffold(backgroundColor: Color(0xFFEFF6FF), body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) return const Scaffold(body: Center(child: Text("Error")));
        if (!snapshot.hasData) return const Scaffold(body: Center(child: Text("Data tidak ada")));

        final d = snapshot.data!;
        final pagePad = EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.06, vertical: 12);

        final header = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFEFF3FF), borderRadius: BorderRadius.circular(10)), child: Text(d.grade, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  context.go('/home', extra: {
                    "type": "category",
                    "value": d.subject,
                  });
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

        final actions = Row(
          children: [
            ActionIconButton(
              icon: pinned ? Icons.push_pin : Icons.push_pin_outlined,
              tooltip: 'Simpan ke pin',
              toggled: pinned,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SaveToPinSheet(
                    noteId: widget.noteId,
                    onSuccess: (namaPapan) {
                      setState(() => pinned = true);
                      _showTopOverlay('Berhasil disimpan ke "$namaPapan"');
                    },
                  ),
                );
              },
            ),

            if (d.izinkanUnduh) ...[
              ActionIconButton(
                icon: _isDownloading ? Icons.hourglass_empty : Icons.download_outlined,
                tooltip: 'Download',
                onTap: () => _downloadImages(d.imageAssets),
              ),
            ],

            ActionIconButton(
              icon: Icons.flag_outlined,
              tooltip: 'Laporkan',
              onTap: () => context.push('/report', extra: d),
            ),
            const Spacer(),
            ActionIconButton(
              icon: liked ? Icons.favorite : Icons.favorite_border,
              tooltip: 'Suka',
              toggled: liked,
              onTap: () => _toggleLike(),
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
          Wrap(spacing: 8, runSpacing: 8, children: d.tags.map((t) {return GestureDetector(onTap: () {context.go('/home', extra: {"type": "tag", "value": t,});}, child: PillTag(t),);}).toList(),),
        ]);

        final mainCard = SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          header, const SizedBox(height: 12),
          ImageCarousel(assets: d.imageAssets), const SizedBox(height: 8),
          actions, const Divider(height: 24),
          description,
        ]));

        final publisherCard = GestureDetector(
          onTap: () => context.push('/profile_user', extra: d.publisher),
          child: PublisherCard(p: d.publisher, authorId: d.authorId),
        );

        return Scaffold(
          backgroundColor: const Color(0xFFEFF6FF),
          appBar: AppBar(backgroundColor: const Color(0xFFEFF6FF), elevation: 0, leading: BackButton(onPressed: () => Navigator.of(context).maybePop())),
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