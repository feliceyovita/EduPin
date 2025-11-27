import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../widgets/profile_widgets.dart';
import '../models/note_details.dart';

const String kFontFamily = 'AlbertSans';

class ProfileUserScreen extends StatelessWidget {
  final Publisher publisher;

  const ProfileUserScreen({super.key, required this.publisher});

  @override
  Widget build(BuildContext context) {
    const double blueHeaderHeight = 152.0;
    const double avatarTopPosition = 82.0;
    const double avatarOuterRadius = 46.0;
    const double avatarInnerRadius = 43.0;

    final notesCollection = FirebaseFirestore.instance.collection('notes');

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

            Positioned(
              top: 45,
              left: 16,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                tooltip: 'Kembali',
              ),
            ),

            Column(
              children: [
                const SizedBox(height: avatarTopPosition),

                CircleAvatar(
                  radius: avatarOuterRadius,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: avatarInnerRadius,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: publisher.avatarAsset.isNotEmpty
                        ? NetworkImage(publisher.avatarAsset)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  publisher.name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E7E96),
                      fontFamily: kFontFamily),
                ),
                const SizedBox(height: 2),
                Text(
                  publisher.handle,
                  style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6E7E96).withOpacity(0.9),
                      fontFamily: kFontFamily),
                ),
                const SizedBox(height: 14),

                // Statistik Catatan & Suka
                StreamBuilder<QuerySnapshot>(
                  stream: notesCollection.where('authorId', isEqualTo: publisher.id).snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ProfileStatColumn(value: "$count", label: 'Catatan'),
                        const SizedBox(width: 40),
                        const ProfileStatColumn(value: "156", label: 'Suka'),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

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
                          offset: const Offset(0, 5))
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

                      StreamBuilder<QuerySnapshot>(
                        stream: notesCollection
                            .where('authorId', isEqualTo: publisher.id)
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final userNotes = snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return {
                              "title": data['title'] ?? 'Tanpa Judul',
                              "category": data['subject'] ?? 'Umum',
                              "description": data['description'] ?? '',
                              "image": (data['imageAssets'] != null && data['imageAssets'].isNotEmpty)
                                  ? data['imageAssets'][0]
                                  : 'assets/images/sample_note.jpeg',
                              "date": data['createdAt'] != null
                                  ? (data['createdAt'] as Timestamp).toDate().toLocal().toString().split(' ')[0]
                                  : '',
                              "pinCount": 0,
                            };
                          }).toList();

                          if (userNotes.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: Text("Belum ada catatan")),
                            );
                          }

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: userNotes.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildNoteCard(userNotes[index]);
                            },
                          );
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
              description: note['description'] ?? 'Deskripsi otomatis dari firebase.',
              subject: note['category'] ?? 'Umum',
              grade: 'Umum',
              school: '', // karena tidak ada di note
              tags: ['Pendidikan', note['category'] ?? 'Umum'],
              imageUrl: note['image'] ?? '', // bisa ambil dari imageAssets[0]
              authorId: publisher.id, // pastikan publisher.id sudah ada
              publisher: publisher,
              imageAssets: [note['image'] ?? 'assets/images/sample_note.jpeg'],
              publikasi: true, // default
              izinkanUnduh: true, // default
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                    image: DecorationImage(
                      image: NetworkImage(note['image'] ?? ''),
                      fit: BoxFit.cover,
                      onError: (e, s) {},
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
      },
    );
  }
}
