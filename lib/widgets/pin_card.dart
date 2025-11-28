import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/note_details.dart';
import 'save_to_pin_sheet.dart';

class PinCard extends StatefulWidget {
  final NoteDetail data;

  const PinCard({super.key, required this.data});

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> {
  bool isLiked = false;
  int likeCount = 156;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
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

          // Info Section
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // --- BAGIAN ICON PIN YANG DIUBAH ---
                    GestureDetector(
                      onTap: () {
                        // 2. TAMPILKAN BOTTOM SHEET (BUKAN PUSH PAGE)
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true, // Biar bisa tinggi
                          backgroundColor: Colors.transparent, // Biar rounded corner kelihatan
                          builder: (context) => SaveToPinSheet(
                            noteId: widget.data.id,

                            // TAMBAHKAN INI:
                            onSuccess: (namaPapan) {
                              // Ini dijalankan ketika berhasil simpan
                              // Kita munculkan SnackBar hijau di Home
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Berhasil disimpan ke "$namaPapan"'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.push_pin_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                    )
                    // -----------------------------------
                  ],
                ),

                const SizedBox(height: 6),

                // Subject
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.data.subject,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),

                const SizedBox(height: 6),

                // Tags
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.data.tags.map((tag) {
                      return Container(
                        margin: const EdgeInsets.only(right: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Text("#$tag", style: const TextStyle(fontSize: 11, color: Colors.blue)),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Publisher + Like button
                Row(
                  children: [
                    Text(
                      "by ${widget.data.publisher.name}",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isLiked = !isLiked;
                          likeCount += isLiked ? 1 : -1;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            likeCount.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
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