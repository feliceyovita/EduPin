import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../widgets/section_card.dart';
import '../models/note_details.dart';

class PublisherCard extends StatelessWidget {
  final Publisher p;
  final String? authorId;

  const PublisherCard({
    super.key,
    required this.p,
    this.authorId,
  });

  @override
  Widget build(BuildContext context) {
    final String uidToFetch = authorId ?? "";

    return SectionCard(
      child: FutureBuilder<DocumentSnapshot>(
        future: (uidToFetch.isNotEmpty)
            ? FirebaseFirestore.instance.collection('users').doc(uidToFetch).get()
            : null,
        builder: (context, snapshot) {

          String? photoUrl;
          String displayName = p.name;
          String displayInst = p.institution;

          if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            photoUrl = data['photoUrl'];
            if (data['nama'] != null) displayName = data['nama'];
            if (data['sekolah'] != null) displayInst = data['sekolah'];
          } else {
            if (p.avatarAsset.startsWith('http')) {
              photoUrl = p.avatarAsset;
            }
          }

          final String inisial = (displayName.isNotEmpty)
              ? displayName[0].toUpperCase()
              : "?";

          return Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF2782FF),
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl) // Pakai NetworkImage untuk URL
                    : null,
                child: (photoUrl == null || photoUrl.isEmpty)
                    ? Text(
                  inisial,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
                    : null,
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(p.handle, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.school_outlined, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Flexible(child: Text(displayInst, style: const TextStyle(color: Colors.black87))),
                    ]),
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