import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/catatan_service.dart';
import '../models/note_details.dart';
import '../widgets/pin_card.dart';
import '../widgets/app_header.dart';

class PapanDetailScreen extends StatefulWidget {
  final String boardName;

  const PapanDetailScreen({super.key, required this.boardName});

  @override
  State<PapanDetailScreen> createState() => _PapanDetailScreenState();
}

class _PapanDetailScreenState extends State<PapanDetailScreen> {
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
          // ===============================================
          // 1. HEADER MENGGUNAKAN WIDGET APPHEADER
          // ===============================================
          SliverToBoxAdapter(
            child: AppHeader(
              hintText: "Cari di papan ini...",
              searchController: _searchC,

              customTitle: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      widget.boardName, // Nama Papan
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
          ),

          FutureBuilder<List<NoteDetail>>(
            future: NotesService().getNotesInBoard(widget.boardName),
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
                    child: Center(child: Text("Error: ${snapshot.error}")),
                  ),
                );
              }

              final notes = snapshot.data ?? [];

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

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final note = notes[index];
                      return PinCard(data: note);
                    },
                    childCount: notes.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 370,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}