import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../widgets/section_card.dart';
import '../models/note_details.dart';

class PublisherCard extends StatelessWidget {
  final Publisher? p;       // <-- sekarang boleh null
  final String? authorId;

  const PublisherCard({
    super.key,
    this.p,                 // <-- tidak required
    this.authorId,
  });

  @override
  Widget build(BuildContext context) {
    final String uidToFetch = authorId ?? "";

    return SectionCard(
      child: FutureBuilder<DocumentSnapshot>(
        future: (uidToFetch.isNotEmpty)
            ? FirebaseFirestore.instance
            .collection('users')
            .doc(uidToFetch)
            .get()
            : null,
        builder: (context, snapshot) {

          // ===== DEFAULT VALUE DARI Publisher (fallback jika p null) =====
          String displayName = p?.name ?? "";
          String displayInst = p?.institution ?? "";
          String? photoUrl = p?.avatarAsset;

          // ===== OVERWRITE DENGAN DATA FIREBASE JIKA ADA =====
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            photoUrl = data['photoUrl'] ?? photoUrl;
            displayName = data['nama'] ?? displayName;
            displayInst = data['sekolah'] ?? displayInst;
          }

          // ===== INISIAL NAMA =====
          final String inisial = (displayName.isNotEmpty)
              ? displayName[0].toUpperCase()
              : "?";

          return Row(
            children: [
              // ===== FOTO PROFIL / INISIAL =====
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2782FF),
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Text(
                  inisial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),

              const SizedBox(width: 12),

              // ===== TEKS INFORMASI PUBLISHER =====
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      p?.handle ?? "",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.school_outlined,
                            size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            displayInst,
                            style:
                            const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
