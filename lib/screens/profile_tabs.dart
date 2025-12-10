import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/note_details.dart';
import '../provider/auth_provider.dart';
import 'detail_catatan.dart';

// Pastikan file widget ini ada, atau hapus import jika tidak pakai
// import '../widgets/profile_widgets.dart';
// import '../utils/custom_notification.dart';

const String kFontFamily = 'AlbertSans';

// ==================================================
// 1. TAMPILAN TAB TENTANG (MODE BACA)
// ==================================================
class ProfileAboutView extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onEditPressed;

  const ProfileAboutView({
    super.key,
    required this.userData,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.grey.shade700;
    const iconSize = 20.0;

    String formatTanggal(dynamic tanggal) {
      if (tanggal is DateTime) {
        return DateFormat('d MMMM yyyy').format(tanggal);
      } else if (tanggal is Timestamp) {
        return DateFormat('d MMMM yyyy').format(tanggal.toDate());
      }
      return '-';
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informasi Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                  fontFamily: kFontFamily,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onEditPressed,
                icon: Image.asset(
                  'assets/images/edit_whole.png',
                  width: 16,
                  height: 16,
                  color: Colors.white,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
                label: const Text(
                  'Edit Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: kFontFamily,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2782FF),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          ProfileInfoRow(
            iconWidget: Image.asset('assets/images/mail.png', width: iconSize, height: iconSize, color: iconColor, errorBuilder: (_,__,___)=> Icon(Icons.mail, size: iconSize, color: iconColor)),
            text: userData['email'] ?? '-',
          ),
          const SizedBox(height: 18),
          ProfileInfoRow(
            iconWidget: Image.asset('assets/images/calender.png', width: iconSize, height: iconSize, color: iconColor, errorBuilder: (_,__,___)=> Icon(Icons.calendar_today, size: iconSize, color: iconColor)),
            text: formatTanggal(userData['tanggalLahir']),
          ),
          const SizedBox(height: 18),
          ProfileInfoRow(
            iconWidget: Image.asset('assets/images/univ.png', width: iconSize, height: iconSize, color: iconColor, errorBuilder: (_,__,___)=> Icon(Icons.school, size: iconSize, color: iconColor)),
            text: userData['sekolah'] ?? '-',
          ),
          const SizedBox(height: 18),
          ProfileInfoRow(
            iconWidget: Image.asset('assets/images/people.png', width: iconSize, height: iconSize, color: iconColor, errorBuilder: (_,__,___)=> Icon(Icons.person, size: iconSize, color: iconColor)),
            text: formatTanggal(userData['createdAt']),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final Widget iconWidget;
  final String text;

  const ProfileInfoRow({super.key, required this.iconWidget, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontFamily: kFontFamily,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================
// 2. TAMPILAN TAB TENTANG (MODE EDIT)
// ==================================================
class ProfileEditForm extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController usernameController;
  final TextEditingController tanggalLahirController;
  final TextEditingController institusiController;
  final VoidCallback onDateTap;

  const ProfileEditForm({
    super.key,
    required this.namaController,
    required this.usernameController,
    required this.tanggalLahirController,
    required this.institusiController,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Personal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: kFontFamily,
            ),
          ),
          const Divider(height: 30),
          ProfileTextField(controller: namaController, label: 'Nama Lengkap'),
          const SizedBox(height: 15),
          ProfileTextField(controller: usernameController, label: 'Username'),
          const SizedBox(height: 15),
          ProfileTextField(
            controller: tanggalLahirController,
            label: 'Tanggal Lahir',
            readOnly: true,
            onTap: onDateTap,
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
          const SizedBox(height: 15),
          ProfileTextField(controller: institusiController, label: 'Institusi'),
        ],
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
            fontFamily: kFontFamily,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            suffixIcon: suffixIcon,
          ),
          style: const TextStyle(
            fontFamily: kFontFamily,
            fontSize: 14,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

// ==================================================
// 3. TAMPILAN TAB CATATAN (FINAL FIX)
// ==================================================
class ProfileNotesTab extends StatefulWidget {
  const ProfileNotesTab({super.key});

  @override
  State<ProfileNotesTab> createState() => _ProfileNotesTabState();
}

class _ProfileNotesTabState extends State<ProfileNotesTab> {
  // Variabel state untuk toggle edit
  bool _isEditingNotes = false;

  void _toggleEdit() {
    setState(() {
      _isEditingNotes = !_isEditingNotes;
    });
    if (!_isEditingNotes) {
      showTopOverlay(context, "Perubahan Tersimpan!");
    }
  }

  String formatTanggal(dynamic tanggal) {
    if (tanggal is Timestamp) return DateFormat('dd/MM/yyyy').format(tanggal.toDate());
    if (tanggal is DateTime) return DateFormat('dd/MM/yyyy').format(tanggal);
    if (tanggal is String) return tanggal;
    return '-';
  }

  void showTopOverlay(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    ));
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .where('authorId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final hasNotes = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catatan Saya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontFamily: kFontFamily,
                    ),
                  ),
                  if (hasNotes)
                    ElevatedButton.icon(
                      onPressed: _toggleEdit,
                      icon: Image.asset(
                        _isEditingNotes
                            ? 'assets/images/save.png'
                            : 'assets/images/edit_whole.png',
                        width: 16,
                        height: 16,
                        color: Colors.white,
                        errorBuilder: (_, __, ___) => Icon(_isEditingNotes ? Icons.save : Icons.edit, size: 16, color: Colors.white),),
                      label: Text(
                        _isEditingNotes ? 'Selesai' : 'Edit Catatan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: kFontFamily,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditingNotes ? const Color(0xFF00C853) : const Color(0xFF2782FF),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 2,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // --- CONTENT ---
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!hasNotes)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/edit_whole.png',
                          width: 50, height: 50, color: Colors.grey.shade300,
                          errorBuilder: (_, __, ___) => Icon(Icons.note_add, size: 50, color: Colors.grey.shade300)),
                      const SizedBox(height: 10),
                      const Text('Belum ada catatan',
                          style: TextStyle(color: Colors.grey, fontFamily: kFontFamily)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final noteMap = {
                      "docId": doc.id,
                      "title": data['title'] ?? 'Tanpa Judul',
                      "description": data['description'] ?? '',
                      "grade": data['grade'] ?? '',
                      "category": data['subject'] ?? 'Umum',
                      "pinCount": data['pinCount'] ?? 0,
                      "date": formatTanggal(data['createdAt']),
                      "authorId": data['authorId'] ?? '',
                      "imageAssets": data['imageAssets'] ?? [],
                      "imageUrl": data['imageUrl'] ?? '',
                      "izinkanUnduh": data['izinkanUnduh'] ?? false,
                      "publikasi": data['publikasi'] ?? false,
                      "publisher": data['publisher'] ?? {},
                      "tags": data['tags'] ?? [],
                    };
                    return _buildNoteCard(noteMap, context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // --- BUILD NOTE CARD DENGAN INKWELL ---
  Widget _buildNoteCard(Map<String, dynamic> note, BuildContext context) {
    final image = (note['imageAssets'] as List).isNotEmpty
        ? NetworkImage(note['imageAssets'][0])
        : const AssetImage('assets/images/default_note.png') as ImageProvider;

    final noteDetailObject = NoteDetail(
      id: note['docId'] ?? '',
      title: note['title'] ?? 'Tanpa Judul',
      description: note['description'] ?? '',
      subject: note['category'] ?? 'Umum',
      grade: note['grade'] ?? '',
      school: note['school'] ?? '',
      tags: List<String>.from(note['tags'] ?? []),
      imageUrl: note['imageUrl'] ?? '',
      authorId: note['authorId'] ?? '',
      publisher: Publisher.fromMap(note['publisher'] ?? {}),
      imageAssets: List<String>.from(note['imageAssets'] ?? []),
      publikasi: note['publikasi'] ?? true,
      izinkanUnduh: note['izinkanUnduh'] ?? true,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NoteDetailPage(noteId: note['docId']),
          ),
        );
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
                image: DecorationImage(image: image, fit: BoxFit.cover),
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
                      Image.asset(
                        'assets/images/pin.png',
                        width: 14,
                        height: 14,
                        color: Colors.grey.shade600,
                        errorBuilder: (_, __, ___) => Icon(Icons.push_pin, size: 14, color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 4),
                      Text('${note['pinCount'] ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: kFontFamily,
                          )),
                      const Spacer(),
                      Text(note['date'] ?? '-',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontFamily: kFontFamily,
                          )),
                    ],
                  ),
                  if (_isEditingNotes) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            context.push('/edit_catatan', extra: noteDetailObject);
                          },
                          icon: Image.asset(
                            'assets/images/edit_2.png',
                            width: 12,
                            height: 12,
                            color: const Color(0xFF2782FF),
                            errorBuilder: (_, __, ___) => const Icon(Icons.edit, size: 12, color: Color(0xFF2782FF)),
                          ),
                          label: const Text('Edit',
                              style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8F1FF),
                            foregroundColor: const Color(0xFF2782FF),
                            side: const BorderSide(color: Color(0xFF2782FF), width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const StadiumBorder(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('notes').doc(note['docId']).delete();
                          },
                          icon: Image.asset(
                            'assets/images/delete.png',
                            width: 12,
                            height: 12,
                            color: Colors.red,
                            errorBuilder: (_, __, ___) => const Icon(Icons.delete, size: 12, color: Colors.red),
                          ),
                          label: const Text('Hapus',
                              style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEBEB),
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red, width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ],
                    )
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// 4. TAMPILAN TAB PENGATURAN
// ==================================================
class ProfileSettingsTab extends StatefulWidget {
  const ProfileSettingsTab({super.key});

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  bool _notificationsEnabled = true;

  void _forceNavigateToLogin(BuildContext context) {
    Navigator.of(context).pop();
    Future.delayed(Duration.zero, () {
      if (context.mounted) context.go('/login');
    });
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                  child: Image.asset('assets/images/logout__red.png',
                      width: 24, height: 24, color: const Color(0xFFEF4444), errorBuilder: (_,__,___)=> const Icon(Icons.logout, color: Color(0xFFEF4444))),
                ),
                const SizedBox(height: 16),
                const Text('Keluar dari akun?',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                        fontFamily: kFontFamily)),
                const SizedBox(height: 6),
                const Text('Sesi akan berakhir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey, fontFamily: kFontFamily)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _forceNavigateToLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Keluar',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: kFontFamily)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                            fontFamily: kFontFamily)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                  child: Image.asset('assets/images/alert__triangle.png',
                      width: 24, height: 24, color: const Color(0xFFEF4444), errorBuilder: (_,__,___)=> const Icon(Icons.warning, color: Color(0xFFEF4444))),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Apakah Anda yakin ingin menghapus akun?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      fontFamily: kFontFamily,
                      height: 1.3),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Data akun ini akan hilang dan tidak bisa dipulihkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey, fontFamily: kFontFamily),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Future.delayed(Duration.zero, () {
                        if (context.mounted) _showPasswordConfirmationDialog(context);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Konfirmasi Hapus Akun',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: kFontFamily)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                            fontFamily: kFontFamily)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPasswordConfirmationDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                      child: Text('Konfirmasi Hapus Akun',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                              fontFamily: kFontFamily))),
                  const Divider(height: 20),
                  Text('Email',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontFamily: kFontFamily)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        hintText: 'Masukkan email anda',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon:
                        const Icon(Icons.mail_outline, color: Colors.grey, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 16)),
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontFamily: kFontFamily, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text('Password',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                          fontFamily: kFontFamily)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Masukkan password anda',
                      hintStyle: const TextStyle(fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                            size: 20),
                        onPressed: () =>
                            setState(() => isPasswordVisible = !isPasswordVisible),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    style: const TextStyle(fontFamily: kFontFamily, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) return;

                        try {
                          User? user = FirebaseAuth.instance.currentUser;
                          AuthCredential credential = EmailAuthProvider.credential(
                            email: email,
                            password: password,
                          );

                          await user!.reauthenticateWithCredential(credential);

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .delete();

                          await user.delete();
                          await FirebaseAuth.instance.signOut();

                          if (context.mounted) {
                            context.read<AuthProvider>().signOut();
                            context.go('/login');
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email atau password salah')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hapus Akun',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: kFontFamily)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengaturan Akun',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                          fontFamily: kFontFamily)),
                  const Divider(height: 30),
                  Row(
                    children: [
                      Image.asset('assets/images/notification.png',
                          width: 24, height: 24, color: Colors.grey.shade700, errorBuilder: (_,__,___)=> const Icon(Icons.notifications, color: Colors.grey)),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notifikasi',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                    fontFamily: kFontFamily)),
                            Text('Terima notifikasi untuk aktivitas baru',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontFamily: kFontFamily),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Switch(
                          value: _notificationsEnabled,
                          onChanged: (val) =>
                              setState(() => _notificationsEnabled = val),
                          activeColor: const Color(0xFF2782FF)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE5E5), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Zona Berbahaya',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE11D48),
                          fontFamily: kFontFamily)),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmationDialog(context),
                      icon: Image.asset('assets/images/delete.png',
                          width: 18, height: 18, color: Colors.red, errorBuilder: (_,__,___)=> const Icon(Icons.delete, size: 18, color: Colors.red)),
                      label: const Text('Hapus Akun',
                          style: TextStyle(
                              fontFamily: kFontFamily,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Color(0xFFFFE5E5), width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmationDialog(context),
                      icon: Image.asset('assets/images/logout_white.png',
                          width: 18, height: 18, errorBuilder: (_,__,___)=> const Icon(Icons.logout, size: 18, color: Colors.white)),
                      label: const Text('Keluar dari Akun',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: kFontFamily)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
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