import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/section_card.dart';
import '../widgets/pill_tag.dart';
import '../widgets/action_icon_button.dart';
import '../widgets/image_carousel.dart';
import '../widgets/publisher_card.dart';

import '../models/note_details.dart';

class NoteDetailPage extends StatefulWidget {
  final NoteDetail data;
  const NoteDetailPage({super.key, required this.data});

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage>
    with AutomaticKeepAliveClientMixin {
  bool pinned = false;
  bool liked = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final d = widget.data;

    final size = MediaQuery.sizeOf(context);
    final pagePad =
    EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: 12);

    // ---------- HEADER ----------
    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(d.grade,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(d.subject,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    // ---------- ACTIONS ----------
    final actions = Row(
      children: [
        ActionIconButton(
          icon: Icons.push_pin_outlined,
          tooltip: pinned ? 'Unpin' : 'Pin',
          toggled: pinned,
          onTap: () => setState(() => pinned = !pinned),
        ),
        ActionIconButton(
          icon: Icons.download_outlined,
          tooltip: 'Download',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Download dummy — nanti diimplementasikan')),
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
        const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(d.description),
        const SizedBox(height: 10),
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.w700)),
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
    final publisherCard = PublisherCard(p: d.publisher);

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF6FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
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

              // Ponsel satu kolom, bisa discroll
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
  }
}
