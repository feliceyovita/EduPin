import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../widgets/profile_widgets.dart';
import '../utils/custom_notification.dart';

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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        // --- EDIT CATATAN PAKAI GO ROUTER ---
                        onPressed: () {
                          context.push('/edit_catatan');
                        },
                        icon: Image.asset('assets/images/edit_2.png',
                            width: 12, height: 12, color: const Color(0xFF2782FF)),
                        label: const Text('Edit',
                            style: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F1FF),
                          foregroundColor: const Color(0xFF2782FF),
                          side: const BorderSide(
                              color: Color(0xFF2782FF), width: 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
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
class ProfileSettingsTab extends StatefulWidget {
  const ProfileSettingsTab({super.key});

  @override
  State<ProfileSettingsTab> createState() => _ProfileSettingsTabState();
}

class _ProfileSettingsTabState extends State<ProfileSettingsTab> {
  bool _notificationsEnabled = true;

  // --- NAVIGASI PAKAI GO ROUTER (ANTI CRASH) ---
  void _forceNavigateToLogin(BuildContext context) {
    // 1. Tutup Dialog (pake context.pop dari GoRouter atau Navigator.pop)
    Navigator.of(context).pop();

    // 2. Langsung Pindah ke Login
    // context.go() akan membersihkan stack dan menjadikan /login halaman utama
    // Ini mencegah error navigtor locked.
    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        context.go('/login');
      }
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
                  decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                  child: Image.asset('assets/images/logout__red.png', width: 24, height: 24, color: const Color(0xFFEF4444)),
                ),
                const SizedBox(height: 16),
                const Text('Keluar dari akun?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333), fontFamily: kFontFamily)),
                const SizedBox(height: 6),
                const Text('Sesi akan berakhir', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: kFontFamily)),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // --- PANGGIL FUNGSI GO ROUTER ---
                    onPressed: () => _forceNavigateToLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48), elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Keluar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: kFontFamily)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151), fontFamily: kFontFamily)),
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
                  decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                  child: Image.asset('assets/images/alert__triangle.png', width: 24, height: 24, color: const Color(0xFFEF4444)),
                ),
                const SizedBox(height: 16),
                const Text('Apakah Anda yakin ingin menghapus akun?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333), fontFamily: kFontFamily, height: 1.3)),
                const SizedBox(height: 6),
                const Text('Data akun ini akan hilang dan tidak bisa dipulihkan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: kFontFamily)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Jeda sedikit sebelum buka dialog password
                      Future.delayed(Duration.zero, () {
                        if (context.mounted) _showPasswordConfirmationDialog(context);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48), elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Konfirmasi Hapus Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: kFontFamily)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Batal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151), fontFamily: kFontFamily)),
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
        return StatefulBuilder(
          builder: (context, setState) {
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
                    const Center(child: Text('Konfirmasi Hapus Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333), fontFamily: kFontFamily))),
                    const Divider(height: 20),
                    Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontFamily: kFontFamily)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(hintText: 'Masukkan email anda', hintStyle: const TextStyle(fontSize: 13), prefixIcon: const Icon(Icons.mail_outline, color: Colors.grey, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16)),
                      keyboardType: TextInputType.emailAddress, style: const TextStyle(fontFamily: kFontFamily, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontFamily: kFontFamily)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Masukkan password anda', hintStyle: const TextStyle(fontSize: 13), prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
                        suffixIcon: IconButton(icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 20), onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                      style: const TextStyle(fontFamily: kFontFamily, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // --- PANGGIL FUNGSI GO ROUTER ---
                        onPressed: () => _forceNavigateToLogin(context),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                        child: const Text('Hapus Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: kFontFamily)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
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
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengaturan Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333), fontFamily: kFontFamily)),
                  const Divider(height: 30),
                  Row(
                    children: [
                      Image.asset('assets/images/notification.png', width: 24, height: 24, color: Colors.grey.shade700),
                      const SizedBox(width: 15),
                      const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Notifikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF333333), fontFamily: kFontFamily)),
                          Text('Terima notifikasi untuk aktivitas baru', style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: kFontFamily), overflow: TextOverflow.ellipsis),
                        ]),
                      ),
                      Switch(value: _notificationsEnabled, onChanged: (val) => setState(() => _notificationsEnabled = val), activeColor: const Color(0xFF2782FF)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFFE5E5), width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Zona Berbahaya', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE11D48), fontFamily: kFontFamily)),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmationDialog(context),
                      icon: Image.asset('assets/images/delete.png', width: 18, height: 18, color: Colors.red),
                      label: const Text('Hapus Akun', style: TextStyle(fontFamily: kFontFamily, fontWeight: FontWeight.bold, fontSize: 15)),
                      style: OutlinedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, side: const BorderSide(color: Color(0xFFFFE5E5), width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogoutConfirmationDialog(context),
                      icon: Image.asset('assets/images/logout_white.png', width: 18, height: 18),
                      label: const Text('Keluar dari Akun', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: kFontFamily)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
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