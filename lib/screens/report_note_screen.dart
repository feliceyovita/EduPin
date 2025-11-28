import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/note_details.dart';
import '../widgets/section_card.dart';

class ReportNoteScreen extends StatelessWidget {
  final NoteDetail note;
  const ReportNoteScreen({super.key, required this.note});

  static const _reasons = [
    ['Spam/Postingan Berulang', 'Catatan/pin yang menyesatkan atau diunggah berulang.'],
    ['Konten Tidak Pantas atau Pornografi', 'Materi yang tidak layak dilihat dan melanggar norma.'],
    ['Konten Melukai Diri Sendiri', 'Mendorong tindakan berbahaya pada diri sendiri/ orang lain.'],
    ['Aktivitas Kebencian/Diskriminasi', 'Mengandung SARA/ujaran kebencian.'],
    ['Pelanggaran Privasi', 'Menyebarkan info pribadi tanpa izin.'],
    ['Kekerasan Grafis', 'Promosi kekerasan eksplisit.'],
    ['Pelecehan/Kritik Destruktif', 'Perundungan, ancaman, atau penghinaan.'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF6FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text('Laporkan Pin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, cons) {
            final maxW = cons.maxWidth >= 700 ? 520.0 : cons.maxWidth - 32.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: SectionCard(
                    padding: EdgeInsets.zero,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _reasons.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1, thickness: 1, color: Color(0x1F000000),
                      ),
                      itemBuilder: (context, i) {
                        final title = _reasons[i][0]!;
                        final subtitle = _reasons[i][1]!;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(subtitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _confirmReport(context, note, title),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmReport(BuildContext context, NoteDetail note, String reason) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Laporkan Pin Ini?',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Kami akan meninjau pin "${note.title}".\nAlasan: $reason',
          style: const TextStyle(fontSize: 14, height: 1.4),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Laporkan'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      final String reporterId = user?.uid ?? 'anonymous';

      await FirebaseFirestore.instance.collection('reports').add({
        'noteId': note.id,
        'noteTitle': note.title,
        'reason': reason,
        'reporterId': reporterId,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'authorId': note.authorId,
      });

      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
              SizedBox(height: 12),
              Text('Terima kasih untuk melaporkan', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 6),
              Text(
                'Laporan Anda telah kami terima dan akan segera ditinjau oleh tim kami.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      );

      if (context.mounted) context.pop();

    } catch (e) {
      debugPrint("Gagal melapor: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim laporan: $e")),
        );
      }
    }
  }
}