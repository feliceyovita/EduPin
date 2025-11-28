import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/catatan_service.dart';

class SaveToPinSheet extends StatelessWidget {
  final String noteId;
  final Function(String) onSuccess; // Callback agar parent tau kalau sukses

  const SaveToPinSheet({
    super.key,
    required this.noteId,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil padding bawah (untuk HP yg ada gesture bar)
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        // WARNA BIRU GRADIENT (SAMA PERSIS)
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.0, 0.73],
          colors: [Color(0xFF4B9CFF), Color(0xFF2272FE)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- HEADER ---
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
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- LIST PAPAN (STREAM BUILDER) ---
          StreamBuilder<QuerySnapshot>(
            stream: NotesService().streamKoleksi(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              final boards = snapshot.data?.docs ?? [];

              if (boards.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Belum ada koleksi. Buat baru yuk!",
                    style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                  ),
                );
              }

              // LIMIT HEIGHT BIAR GAK KEPANJANGAN
              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: boards.length,
                  itemBuilder: (context, index) {
                    final data = boards[index].data() as Map<String, dynamic>;
                    final namaPapan = data['name'] ?? 'Tanpa Nama';

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context); // Tutup sheet
                          try {
                            // Simpan ke database
                            await NotesService().simpanKePin(noteId, namaPapan);

                            // Panggil callback sukses (biar parent yg munculin notifikasi)
                            onSuccess(namaPapan);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal: $e")),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  color: Colors.white24, // Placeholder transparan
                                  child: const Icon(Icons.folder, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  namaPapan,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Icon(Icons.add_circle_outline, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // --- TOMBOL BUAT BARU ---
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              context.push('/pin_baru');
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.add, color: Color(0xFF2272FE), size: 30),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Buat koleksi baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}