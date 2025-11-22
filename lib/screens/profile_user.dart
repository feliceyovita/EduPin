import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/profile_widgets.dart';
import '../models/note_details.dart';

const String kFontFamily = 'AlbertSans';

class ProfileUserScreen extends StatelessWidget {
  final Publisher publisher;

  const ProfileUserScreen({super.key, required this.publisher});

  @override
  Widget build(BuildContext context) {
    // --- DIMENSI LAYOUT ---
    const double blueHeaderHeight = 152.0;
    const double avatarTopPosition = 82.0;
    const double avatarOuterRadius = 46.0;
    const double avatarInnerRadius = 43.0;

    // Data Dummy Catatan
    final List<Map<String, dynamic>> userNotes = [
      {
        "title": "Integral Parsial dan Contoh Soal",
        "category": "Matematika",
        "pinCount": 23,
        "date": "20/09/2025",
        "image": "assets/images/integral.png"
      },
      {
        "title": "Struktur Data Stack dan Queue",
        "category": "Informatika",
        "pinCount": 18,
        "date": "20/09/2025",
        "image": "assets/images/strukdat.png"
      },
      {
        "title": "Konsep Dasar Machine Learning",
        "category": "Teknologi",
        "pinCount": 156,
        "date": "18/09/2025",
        "image": "assets/images/sample_note.jpeg"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: blueHeaderHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [Color(0xFF4FA0FF), Color(0xFF2A7EFF), Color(0xFF165EFC)],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),

            // 2. TOMBOL BACK (KEMBALI)
            Positioned(
              top: 45,
              left: 16,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                tooltip: 'Kembali',
              ),
            ),

            // 3. KONTEN UTAMA
            Column(
              children: [
                const SizedBox(height: avatarTopPosition),

                CircleAvatar(
                  radius: avatarOuterRadius,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: avatarInnerRadius,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: AssetImage(publisher.avatarAsset),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  publisher.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E7E96),
                      fontFamily: kFontFamily
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  publisher.handle,
                  style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6E7E96).withOpacity(0.9),
                      fontFamily: kFontFamily
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfileStatColumn(value: "${userNotes.length}", label: 'Catatan'),
                    const SizedBox(width: 40),
                    const ProfileStatColumn(value: "156", label: 'Suka'),
                  ],
                ),

                const SizedBox(height: 20),

                // --- KOTAK PUTIH DAFTAR CATATAN ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5)
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                          fontFamily: kFontFamily,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List Catatan
                      userNotes.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text("Belum ada catatan")),
                      )
                          : ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userNotes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildNoteCard(userNotes[index]);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    return Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              final noteDetailObj = NoteDetail(
                id: 'id_${note['title']}',
                title: note['title'] ?? 'Tanpa Judul',
                subject: note['category'] ?? 'Umum',
                grade: 'Umum',
                tags: ['Pendidikan', note['category'] ?? 'Umum'],
                description: 'Ini adalah deskripsi lengkap dari catatan "${note['title']}". Konten ini digenerate otomatis dari halaman profil user.',
                imageAssets: [note['image'] ?? 'assets/images/sample_note.jpeg'],
                publisher: publisher,
              );

              context.push('/detail', extra: noteDetailObj);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade200,
                      image: DecorationImage(
                        image: AssetImage(note['image'] ?? ''),
                        fit: BoxFit.cover,
                        onError: (e, s) {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note['title'] ?? 'Tanpa Judul',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                            fontFamily: kFontFamily,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          note['category'] ?? 'Umum',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontFamily: kFontFamily,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Image.asset('assets/images/pin.png', width: 14, height: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text('${note['pinCount']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontFamily: kFontFamily)),
                            const Spacer(),
                            Text(note['date'], style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontFamily: kFontFamily)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}