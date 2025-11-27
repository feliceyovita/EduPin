import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/catatan_service.dart';

class PapanScreen extends StatefulWidget {
  const PapanScreen({super.key});

  @override
  State<PapanScreen> createState() => _PapanScreenState();
}

class _PapanScreenState extends State<PapanScreen> {
  final _searchC = TextEditingController();

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // -------- HEADER --------
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: Colors.blue,
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45), // Jarak status bar

                  // Judul + Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Pastikan aset logo ada, kalau tidak pakai Icon dulu
                        Image.asset(
                          'assets/images/logo.png', // Ganti icon kalau error
                          width: 36,
                          height: 36,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.dashboard, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "EduPin",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Search Bar
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: TextField(
                          controller: _searchC,
                          decoration: const InputDecoration(
                            hintText: "Cari Papan",
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------- STREAM GRID PAPAN --------
          StreamBuilder<QuerySnapshot>(
            stream: NotesService().streamKoleksi(),
            builder: (context, snapshot) {
              // 1. Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // 2. Error
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Error: ${snapshot.error}"),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // 3. Kosong
              if (docs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Belum ada papan koleksi.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }

              // 4. Ada Data
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final boardName = data['name'] ?? 'Tanpa Nama';

                      // Panggil Widget Card yang sudah dipisah
                      return _PapanCard(boardName: boardName);
                    },
                    childCount: docs.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.75, // Disesuaikan biar muat teks
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // Floating Action Button untuk tambah Papan Manual
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/pin_baru'),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ============================================
// WIDGET KARTU PAPAN (TERPISAH BIAR RAPI)
// ============================================
class _PapanCard extends StatelessWidget {
  final String boardName;

  const _PapanCard({required this.boardName});

  // Fungsi "Pande-pande" mencari gambar cover
  // Logikanya: Cari pin terakhir di papan ini -> Ambil Note ID -> Ambil Gambar Note itu
  Future<Map<String, dynamic>> _getPapanInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'image': null, 'count': 0};

    final db = FirebaseFirestore.instance;

    // 1. Ambil Pin di papan ini
    final pinQuery = await db
        .collection('users')
        .doc(user.uid)
        .collection('pins')
        .where('collection', isEqualTo: boardName)
        .orderBy('savedAt', descending: true)
        .get();

    final count = pinQuery.docs.length;
    String? imageUrl;

    // 2. Kalau ada pin, ambil noteId pin pertama (terbaru)
    if (pinQuery.docs.isNotEmpty) {
      final noteId = pinQuery.docs.first.data()['noteId'];

      // 3. Ambil detail note untuk dapat gambarnya
      try {
        final note = await NotesService().getNoteById(noteId);
        if (note.imageAssets.isNotEmpty) {
          imageUrl = note.imageAssets.first;
        }
      } catch (e) {
        // Ignore error kalau note sudah dihapus tapi pin masih ada
      }
    }

    return {'image': imageUrl, 'count': count};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getPapanInfo(),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data?['image'];
        final count = snapshot.data?['count'] ?? 0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        // --- DISINI LETAKNYA ---
        // Kita bungkus Column dengan GestureDetector biar bisa diklik
        return GestureDetector(
          onTap: () {
            // Navigasi ke halaman detail papan sambil bawa nama papannya
            context.push('/papan_detail', extra: boardName);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // GAMBAR KOTAK FULL
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
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : imageUrl != null
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                        : _placeholder(),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // NAMA PAPAN
              Text(
                boardName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // JUMLAH PIN
              Text(
                "$count pin",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
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