import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/profile_widgets.dart';

// 1. TAMPILAN ABOUT
class ProfileAboutView extends StatelessWidget {
  final Map<String, dynamic> userData;
  final VoidCallback onEditPressed;
  const ProfileAboutView({super.key, required this.userData, required this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.grey.shade700;
    const iconSize = 20.0;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: Column( // Langsung Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Informasi Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              ElevatedButton.icon(
                onPressed: onEditPressed,
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                label: const Text('Edit Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2782FF), shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), elevation: 2),
              ),
            ],
          ),
          const Divider(height: 30),
          ProfileInfoRow(iconWidget: Image.asset('assets/images/mail.png', width: iconSize, height: iconSize, color: iconColor), text: userData['email']),
          const SizedBox(height: 18),
          ProfileInfoRow(iconWidget: Image.asset('assets/images/calender.png', width: iconSize, height: iconSize, color: iconColor), text: DateFormat('d MMMM yyyy').format(userData['tanggalLahir'])),
          const SizedBox(height: 18),
          ProfileInfoRow(iconWidget: Image.asset('assets/images/univ.png', width: iconSize, height: iconSize, color: iconColor), text: userData['institusi']),
          const SizedBox(height: 18),
          ProfileInfoRow(iconWidget: Image.asset('assets/images/people.png', width: iconSize, height: iconSize, color: iconColor), text: userData['bergabung']),
        ],
      ),
    );
  }
}

// 2. TAMPILAN FORM EDIT (SingleChildScrollView dihapus)
class ProfileEditForm extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController usernameController;
  final TextEditingController tanggalLahirController;
  final TextEditingController institusiController;
  final VoidCallback onDateTap;
  const ProfileEditForm({super.key, required this.namaController, required this.usernameController, required this.tanggalLahirController, required this.institusiController, required this.onDateTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: Column( // Langsung Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          const Divider(height: 30),
          ProfileTextField(controller: namaController, label: 'Nama Lengkap'),
          const SizedBox(height: 15),
          ProfileTextField(controller: usernameController, label: 'Username'),
          const SizedBox(height: 15),
          ProfileTextField(controller: tanggalLahirController, label: 'Tanggal Lahir', readOnly: true, onTap: onDateTap, suffixIcon: const Icon(Icons.calendar_today_outlined)),
          const SizedBox(height: 15),
          ProfileTextField(controller: institusiController, label: 'Institusi'),
        ],
      ),
    );
  }
}

// 3. TAMPILAN CATATAN (Sudah OK)
class ProfileNotesTab extends StatelessWidget {
  const ProfileNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text('Belum ada catatan', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// 4. TAMPILAN PENGATURAN (Sudah OK)
class ProfileSettingsTab extends StatelessWidget {
  const ProfileSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings_outlined, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text('Pengaturan Akun', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}