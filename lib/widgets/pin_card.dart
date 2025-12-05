import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/note_details.dart';
import '../services/catatan_service.dart';
import 'save_to_pin_sheet.dart';

class PinCard extends StatefulWidget {
  final NoteDetail data;
  final Function(String) onCategoryTap;
  final Function(String) onTagTap;

  const PinCard({
    super.key,
    required this.data,
    required this.onCategoryTap,
    required this.onTagTap,
  });

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> {
  bool pinned = false;
  bool isLiked = false;
  int likeCount = 156;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _checkIfPinned();
  }

  void _checkIfPinned() async {
    bool status = await NotesService().isPinned(widget.data.id);
    if (mounted) setState(() => pinned = status);
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  void _togglePin() async {
    if (!pinned) {
      // BELUM DIPIN → tampilkan bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SaveToPinSheet(
          noteId: widget.data.id,
          onSuccess: (namaPapan) async {
            await NotesService().pinNote(widget.data.id, namaKoleksi: namaPapan);
            if (mounted) setState(() => pinned = true);
            _showTopOverlay('Berhasil disimpan ke "$namaPapan"');
          },
        ),
      );
    } else {
      // SUDAH DIPIN → unpin langsung
      await NotesService().unpinNote(widget.data.id);
      if (mounted) setState(() => pinned = false);
      _showTopOverlay('Catatan dihapus dari pin');
    }
  }

  void _showTopOverlay(String message, {Duration duration = const Duration(seconds: 2)}) {
    _overlayEntry?.remove();
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final topPadding = MediaQuery.of(context).viewPadding.top + 8.0;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.publikasi == false) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => context.push('/detail_catatan', extra: widget.data.id),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                widget.data.imageUrl.isNotEmpty
                    ? widget.data.imageUrl
                    : "https://placehold.co/600x400?text=No+Image",
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    GestureDetector(
                      onTap: _togglePin,
                      child: Icon(
                        pinned ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 18,
                        color: pinned ? Color(0xFF2782FF) : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => widget.onCategoryTap(widget.data.subject),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF2782FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.data.subject,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.data.tags.map((tag) {
                      return GestureDetector(
                        onTap: () => widget.onTagTap(tag),
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Text("#$tag", style: const TextStyle(fontSize: 11, color: Colors.blue)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "by ${widget.data.publisher.name}",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: Color(0xFF2782FF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likeCount.toString(),
                            style: TextStyle(fontSize: 12, color: Color(0xFF2782FF), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}