import 'package:flutter/material.dart';
import '../../../widgets/section_card.dart';
import '../models/note_details.dart';

class PublisherCard extends StatelessWidget {
  final Publisher p;
  const PublisherCard({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: AssetImage(p.avatarAsset)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(p.handle, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.school_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 6),
                  Flexible(child: Text(p.institution, style: const TextStyle(color: Colors.black87))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
