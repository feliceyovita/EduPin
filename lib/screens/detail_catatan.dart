import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/catatan_service.dart';
import '../widgets/buttom_sheet.dart';
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
  bool pinned = false;
  bool liked = false;

  OverlayEntry? _overlayEntry;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _removeOverlayIfAny();
    super.dispose();
  }

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
                    const Icon(Icons.check_circle_outline,
                        color: Colors.white),
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

  // --------- BOTTOM SHEET SIMPAN DI PIN ANDA ----------
  void _showPinSheet() {
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
                Color(0xFF4B9CFF),
                Color(0xFF2272FE),
              ],
            ),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Simpan di pin anda',
                    textAlign: TextAlign.center,
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
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () {
                  _showTopOverlay('Disimpan ke "Materi UTS"');
                  Navigator.pop(ctx);
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

              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/pin_baru');
                },
                child: Container(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF2272FE),
                          size: 30,
                        ),
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
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<NoteDetail>(
      future: NotesService().getNoteById(widget.noteId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
            ActionIconButton(
              icon: Icons.push_pin_outlined,
              tooltip: pinned ? 'Lepas dari pin' : 'Simpan ke pin',
              toggled: pinned,
              onTap: () {
                setState(() => pinned = !pinned);
                if (pinned) _showPinSheet();
              },
            ),
            ActionIconButton(
              icon: Icons.download_outlined,
              tooltip: 'Download',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download dummy — nanti diimplementasikan'),
                ),
              ),
            ),
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

        final publisherCard = GestureDetector(
          onTap: () {
            context.push('/profile_user', extra: d.publisher);
          },
          child: PublisherCard(p: d.publisher),
        );

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
