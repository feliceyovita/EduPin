import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../widgets/profile_widgets.dart';
import '../models/note_details.dart';

const String kFontFamily = 'AlbertSans';

class ProfileUserScreen extends StatelessWidget {
  final String authorId;

  const ProfileUserScreen({super.key, required this.authorId});

  Future<int> _countTotalLikes(String authorId) async {
    debugPrint("CHECK AUTHOR ID: $authorId");
    final notesQuery = await FirebaseFirestore.instance
        .collection('notes')
        .where('authorId', isEqualTo: authorId)
        .get();

    debugPrint("TOTAL NOTES FOUND: ${notesQuery.docs.length}");

    int totalLikes = 0;

    for (var note in notesQuery.docs) {
      final likesSnapshot = await FirebaseFirestore.instance
          .collection('notes')
          .doc(note.id)
          .collection('likes')
          .get();

      debugPrint("NOTE ${note.id} LIKE COUNT: ${likesSnapshot.docs.length}");
      totalLikes += likesSnapshot.docs.length;
    }

    debugPrint("TOTAL LIKES FINAL: $totalLikes");
    return totalLikes;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String authorId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(authorId)
        .snapshots();
  }

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
                      colors: [
                        Color(0xFF4FA0FF),
                        Color(0xFF2A7EFF),
                        Color(0xFF165EFC)
                      ],
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
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                tooltip: 'Kembali',
              ),
            ),

            Column(
              children: [
                const SizedBox(height: avatarTopPosition),

                // ============================
                //       FOTO PROFIL USER
                // ============================
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: getUserStream(authorId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                      return const Text("User tidak ditemukan");
                    }

                    final data = snapshot.data!.data();

                    // -------------------------------------------------
                    // 1. LOGIKA NAMA
                    // -------------------------------------------------
                    String displayName = data?['nama'] ?? data?['name'] ?? "Tanpa Nama";

                    if (displayName.isEmpty) {
                      displayName = data?['username'] ?? "User";
                    }

                    // -------------------------------------------------
                    // 2. LOGIKA USERNAME
                    // -------------------------------------------------
                    String rawUsername = data?['username'] ?? data?['handle'] ?? "";
                    String displayHandle = "";

                    if (rawUsername.contains('@')) {
                      displayHandle = "@${rawUsername.split('@')[0]}";
                    } else {
                      displayHandle = rawUsername.startsWith('@') ? rawUsername : "@$rawUsername";
                    }

                    String photoUrl = data?['photoUrl'] ?? '';

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: avatarOuterRadius,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: avatarInnerRadius,
                            backgroundColor: (photoUrl.isEmpty)
                                ? const Color(0xFF2A7EFF)  // background biru jika kosong
                                : Colors.grey.shade200,
                            backgroundImage: (photoUrl.isNotEmpty && photoUrl.startsWith('http'))
                                ? NetworkImage(photoUrl)
                                : null,
                            child: (photoUrl.isEmpty)
                                ? Text(
                              (displayName.isNotEmpty ? displayName[0].toUpperCase() : "?"),
                              style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6E7E96),
                            fontFamily: kFontFamily,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 2),

                        Text(
                          displayHandle,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF6E7E96).withOpacity(0.9),
                            fontFamily: kFontFamily,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 14),

                // ===============================
                //        CATATAN & SUKA
                // ===============================
                FutureBuilder<int>(
                  future: _countTotalLikes(authorId),

                  builder: (context, snapshot) {
                    final totalLikes = snapshot.data ?? 0;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notes')
                          .where('authorId', isEqualTo: authorId)
                          .snapshots(),
                      builder: (context, noteSnapshot) {
                        final noteCount = noteSnapshot.data?.docs.length ?? 0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ProfileStatColumn(
                              value: "$noteCount",
                              label: 'Catatan',
                            ),
                            const SizedBox(width: 40),
                            ProfileStatColumn(
                              value: "$totalLikes",
                              label: 'Suka',
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ===============================
                //         LIST CATATAN
                // ===============================
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
                        offset: const Offset(0, 5),
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

                      StreamBuilder<QuerySnapshot>(
                        stream: notesCollection
                            .where('authorId', isEqualTo: authorId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final userNotes = snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return {
                              "id": doc.id,
                              "title": data['title'] ?? 'Tanpa Judul',
                              "category": data['subject'] ?? 'Umum',
                              "description": data['description'] ?? '',
                              "image": (data['imageAssets'] != null &&
                                  data['imageAssets'].isNotEmpty)
                                  ? data['imageAssets'][0]
                                  : 'assets/images/sample_note.jpeg',
                              "date": data['createdAt'] != null
                                  ? (data['createdAt'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                                  : '',
                              "pinCount": (data['likes'] is List)
                                  ? data['likes'].length
                                  : 0,
                              "authorId": data['authorId'],
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
                            separatorBuilder: (context, _) =>
                            const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildNoteCard(context, userNotes[index]);
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

  // =========================================
  //                KARTU CATATAN
  // =========================================
  Widget _buildNoteCard(BuildContext context, Map<String, dynamic> note) {
    return GestureDetector(
      onTap: () {
        final noteDetailObj = NoteDetail(
          id: note['id'],
          title: note['title'],
          description: note['description'],
          subject: note['category'],
          grade: 'Umum',
          school: '',
          tags: ['Pendidikan', note['category']],
          imageUrl: note['image'],
          authorId: note['authorId'],
          publisher: null, // publisher tidak dibutuhkan
          imageAssets: [note['image']],
          publikasi: true,
          izinkanUnduh: true,
        );

        context.push('/detail_catatan', extra: noteDetailObj.id);
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
                  image: NetworkImage(note['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note['title'],
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
                    note['category'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontFamily: kFontFamily,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Spacer(),
                      Text(
                        note['date'] ?? '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                          fontFamily: kFontFamily,
                        ),
                      ),
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
}
