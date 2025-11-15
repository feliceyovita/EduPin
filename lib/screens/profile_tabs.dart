import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/profile_widgets.dart';
import '../utils/custom_notification.dart';

import 'edit_catatan_screen.dart';

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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const Divider(height: 30),

          ProfileInfoRow(
            iconWidget: Image.asset('assets/images/mail.png',
                width: iconSize, height: iconSize, color: iconColor),
            text: userData['email'] ?? '-',
          ),
          const SizedBox(height: 18),
          ProfileInfoRow(
            iconWidget: Image.asset('assets/images/calender.png',
                width: iconSize, height: iconSize, color: iconColor),
            text: formatTanggal(userData['tanggalLahir']),
          ),
          const SizedBox(height: 18),
          ProfileInfoRow(
            iconWidget: Image.asset('assets/images/univ.png',
                width: iconSize, height: iconSize, color: iconColor),
            text: userData['institusi'] ?? '-',
          ),
          const SizedBox(height: 18),
          ProfileInfoRow(
            iconWidget: Image.asset('assets/images/people.png',
                width: iconSize, height: iconSize, color: iconColor),
            text: userData['bergabung'] ?? '-',
          ),
        ],
      ),
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
          const Text('Informasi Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
                fontFamily: kFontFamily,
              )),
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
              suffixIcon: const Icon(Icons.calendar_today_outlined)),
          const SizedBox(height: 15),
          ProfileTextField(controller: institusiController, label: 'Institusi'),
        ],
      ),
    );
  }
}

// ==================================================
// 3. TAMPILAN TAB CATATAN
// ==================================================
class ProfileNotesTab extends StatefulWidget {
  const ProfileNotesTab({super.key});

  @override
  State<ProfileNotesTab> createState() => _ProfileNotesTabState();
}

class _ProfileNotesTabState extends State<ProfileNotesTab> {
  bool _isEditingNotes = false;

  final List<Map<String, dynamic>> _notes = [
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
  ];

  void _toggleEdit() {
    setState(() {
      _isEditingNotes = !_isEditingNotes;
    });
    if (!_isEditingNotes) {
      showTopOverlay(context, "Perubahan Tersimpan!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
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
              ElevatedButton.icon(
                onPressed: _toggleEdit,
                icon: Image.asset(
                  _isEditingNotes
                      ? 'assets/images/save.png'
                      : 'assets/images/edit_whole.png',
                  width: 16,
                  height: 16,
                  color: Colors.white,
                ),
                label: Text(
                  _isEditingNotes ? 'Selesai' : 'Edit Catatan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: kFontFamily,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditingNotes
                      ? const Color(0xFF00C853)
                      : const Color(0xFF2782FF),
                  shape: const StadiumBorder(),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _notes.isEmpty
              ? Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/edit_whole.png',
                    width: 50, height: 50, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                const Text('Belum ada catatan',
                    style: TextStyle(
                        color: Colors.grey, fontFamily: kFontFamily)),
              ],
            ),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notes.length,
            separatorBuilder: (context, index) =>
            const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final note = _notes[index];
              return _buildNoteCard(note, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, BuildContext context) {
    return Container(
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
          // Gambar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
              image: DecorationImage(
                image: AssetImage(note['image'] ?? ''),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Kolom Informasi (Kanan)
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
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${note['pinCount'] ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: kFontFamily,
                      ),
                    ),
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

                if (_isEditingNotes) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start, // Rata Kiri
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditCatatanScreen()),
                          );
                        },
                        icon: Image.asset('assets/images/edit_2.png',
                            width: 12, height: 12, color: const Color(0xFF2782FF)),
                        label: const Text('Edit',
                            style: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F1FF),
                          foregroundColor: const Color(0xFF2782FF),
                          side: const BorderSide(color: Color(0xFF2782FF), width: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), // Ramping
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: const StadiumBorder(),
                        ),
                      ),
                      const SizedBox(width: 10),

                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Image.asset('assets/images/delete.png',
                            width: 12, height: 12, color: Colors.red),
                        label: const Text('Hapus',
                            style: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFEBEB),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), // Ramping
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
    );
  }
}

// ==================================================
// 4. TAMPILAN TAB PENGATURAN
// ==================================================
class ProfileSettingsTab extends StatelessWidget {
  const ProfileSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Pengaturan Akun',
              style: TextStyle(color: Colors.grey, fontFamily: kFontFamily),
            ),
          ],
        ),
      ),
    );
  }
}