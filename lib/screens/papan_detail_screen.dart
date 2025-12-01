import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/catatan_service.dart';
import '../models/note_details.dart';
import '../widgets/pin_card.dart';

class PapanDetailScreen extends StatefulWidget {
  final String boardName;

  const PapanDetailScreen({super.key, required this.boardName});

  @override
  State<PapanDetailScreen> createState() => _PapanDetailScreenState();
}

class _PapanDetailScreenState extends State<PapanDetailScreen> {
  // Controller search (biar ada visualnya dulu)
  final _searchC = TextEditingController();

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Samakan warna background
      body: CustomScrollView(
        slivers: [
          // ===============================================
          // 1. HEADER
          // ===============================================
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: Colors.blue,
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35), // Jarak status bar

                  // Baris Atas: Tombol Back + Judul Papan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        // GANTI LOGO JADI TOMBOL BACK
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            widget.boardName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // SEARCH BAR
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
                            hintText: "Cari di papan ini...",
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

          // ===============================================
          // 2. ISI KONTEN (RESPONSIF GRID)
          // ===============================================
          FutureBuilder<List<NoteDetail>>(
            future: NotesService().getNotesInBoard(widget.boardName),
            builder: (context, snapshot) {
              // A. Loading
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // B. Error
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  ),
                );
              }

              final notes = snapshot.data ?? [];

              // C. Kosong
              if (notes.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notes, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Belum ada catatan di sini.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }

              // D. Ada Data -> Tampilkan Grid (RESPONSIF)
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                // --- PAKAI SliverLayoutBuilder AGAR BISA HITUNG LEBAR LAYAR ---
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    // Logic: Lebar ideal kartu sekitar 200px.
                    // Jika layar 400px (HP Portrait) -> 2 Kolom
                    // Jika layar 800px (HP Landscape) -> 4 Kolom
                    double itemWidth = 200;
                    int crossAxisCount = (constraints.crossAxisExtent / itemWidth).floor();

                    // Pastikan minimal 2 kolom
                    if (crossAxisCount < 2) crossAxisCount = 2;

                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final note = notes[index];
                          return PinCard(data: note);
                        },
                        childCount: notes.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount, // Gunakan hasil hitungan
                        mainAxisExtent: 370, // Tinggi kartu tetap
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}