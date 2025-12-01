import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/catatan_service.dart';
import '../widgets/app_header.dart'; // <--- IMPORT WIDGET HEADER

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
          // ===========================================
          // 1. HEADER (SUDAH PAKAI WIDGET APPHEADER)
          // ===========================================
          SliverToBoxAdapter(
            child: AppHeader(
              hintText: "Cari Papan",
              searchController: _searchC,
            ),
          ),

          // ===========================================
          // 2. STREAM GRID PAPAN (RESPONSIF)
          // ===========================================
          StreamBuilder<QuerySnapshot>(
            stream: NotesService().streamKoleksi(),
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
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Error: ${snapshot.error}"),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              // C. Kosong
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

              // D. Ada Data -> Grid Responsif
              // --- GUNAKAN SliverLayoutBuilder AGAR BISA MENGHITUNG LEBAR ---
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    // Logic hitung kolom:
                    // Asumsi lebar ideal satu kartu adalah 160 pixel.
                    // Jadi: Lebar Layar / 160 = Jumlah Kolom.
                    final double itemWidth = 160;
                    int crossAxisCount = (constraints.crossAxisExtent / itemWidth).floor();

                    // Pastikan minimal 2 kolom (biar gak aneh kalau layar sempit banget)
                    if (crossAxisCount < 2) crossAxisCount = 2;

                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final boardName = data['name'] ?? 'Tanpa Nama';
                          final boardId = doc.id;

                          return _PapanCard(
                            boardName: boardName,
                            boardId: boardId,
                          );
                        },
                        childCount: docs.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount, // Gunakan hasil hitungan
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.75, // Rasio tinggi kartu
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),

      // FAB TAMBAH
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/pin_baru'),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ============================================
// WIDGET KARTU PAPAN (SAMA SEPERTI SEBELUMNYA)
// ============================================
class _PapanCard extends StatelessWidget {
  final String boardName;
  final String boardId;

  const _PapanCard({required this.boardName, required this.boardId});

  // --- HAPUS FUNGSI _getPapanInfo YANG LAMA (SUDAH DIGANTI SERVICE) ---

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
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              Text("Opsi Papan: $boardName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline, color: Colors.red)),
                title: const Text("Hapus Papan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                subtitle: const Text("Papan dan semua isinya akan dihapus permanen"),
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
        content: Text("Apakah Anda yakin ingin menghapus papan \"$boardName\"? Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menghapus papan...")));
              try {
                await NotesService().hapusPapan(boardId, boardName);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Papan berhasil dihapus")));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: NotesService().streamPinsInBoard(boardName),
      builder: (context, snapshot) {
        String? imageUrl;
        int count = 0;
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final data = snapshot.data!.first;
          count = data['count'];
          imageUrl = data['image'];
          isLoading = false;
        }

        return GestureDetector(
          onTap: () {
            context.push('/papan_detail', extra: boardName);
          },
          onLongPress: () {
            _showOptions(context);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
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

              Text(
                boardName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 4),

              Text(
                  "$count pin",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)
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