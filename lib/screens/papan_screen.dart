import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/catatan_service.dart';
import '../widgets/app_header.dart';

class PapanScreen extends StatefulWidget {
  const PapanScreen({super.key});

  @override
  State<PapanScreen> createState() => _PapanScreenState();
}

class _PapanScreenState extends State<PapanScreen> {
  final _searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchC.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth > 600 ? 3 : 2;

    double childAspectRatio = 0.7;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          AppHeader(
            hintText: "Cari Papan",
            searchController: _searchC,
          ),

          Expanded(
            child: CustomScrollView(
              slivers: [
                StreamBuilder<QuerySnapshot>(
                  stream: NotesService().streamKoleksi(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text("Error: ${snapshot.error}"),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    final filteredDocs = docs.where((doc) {
                      final name = (doc.data() as Map<String, dynamic>)['name']
                          ?.toString()
                          .toLowerCase() ??
                          "";
                      final keyword = _searchC.text.toLowerCase();
                      return name.contains(keyword);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_open,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text("Tidak ditemukan papan",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final doc = filteredDocs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final boardName = data['name'] ?? 'Tanpa Nama';
                            final boardId = doc.id;

                            return _PapanCard(
                              boardName: boardName,
                              boardId: boardId,
                            );
                          },
                          childCount: filteredDocs.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: childAspectRatio,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/pin_baru'),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _PapanCard extends StatelessWidget {
  final String boardName;
  final String boardId;

  const _PapanCard({required this.boardName, required this.boardId});

  // 1. Ganti jadi Stream agar update otomatis
  Stream<QuerySnapshot> _getPinStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .where('collection', isEqualTo: boardName)
        .orderBy('savedAt', descending: true) // Urutkan dari yang terbaru
        .snapshots(); // <--- KUNCI REALTIME UPDATE
  }

  // Helper untuk ambil URL gambar dari noteId
  Future<String?> _getCoverImage(String noteId) async {
    try {
      final note = await NotesService().getNoteById(noteId);
      if (note.imageAssets.isNotEmpty) {
        return note.imageAssets.first;
      }
    } catch (_) {}
    return null;
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              Text("Opsi Papan: $boardName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text("Hapus Papan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Papan?"),
        content: Text("Yakin hapus papan \"$boardName\"? ini tidak bisa dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Menghapus papan...")),
              );
              try {
                await NotesService().hapusPapan(boardId, boardName);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Papan berhasil dihapus")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menghapus: $e")),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Gunakan StreamBuilder di sini
    return StreamBuilder<QuerySnapshot>(
      stream: _getPinStream(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final count = docs.length;

        // Ambil noteId terbaru untuk dijadikan cover
        final latestNoteId = docs.isNotEmpty ? docs.first['noteId'] : null;

        return GestureDetector(
          onTap: () {
            context.push('/papan_detail', extra: boardName);
          },
          onLongPress: () => _showOptions(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: latestNoteId == null
                        ? _placeholder() // Jika kosong langsung placeholder
                        : FutureBuilder<String?>(
                      // Fetch gambar hanya untuk item terbaru
                      future: _getCoverImage(latestNoteId),
                      builder: (context, imgSnapshot) {
                        if (imgSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(color: Colors.grey[100]); // Loading state ringan
                        }
                        final imageUrl = imgSnapshot.data;

                        if (imageUrl != null) {
                          return Image.network(imageUrl, fit: BoxFit.cover);
                        } else {
                          return _placeholder();
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      boardName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$count pin", // Ini akan otomatis berubah sekarang
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.folder_outlined, size: 40, color: Colors.grey),
    );
  }
}