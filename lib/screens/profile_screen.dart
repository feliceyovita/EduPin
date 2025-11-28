import 'dart:io'; // Import ini untuk File
import 'package:edupin/screens/profile_tabs.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../provider/auth_provider.dart';
import '../utils/custom_notification.dart';
import '../widgets/profile_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isUploadingImage = false; // Loading state untuk upload gambar
  late TabController _tabController;

  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _institusiController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() async {
      await auth.loadUserProfile();
      if (mounted) {
        _loadToControllers(auth.userProfile);
      }
    });

    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _loadToControllers(Map<String, dynamic>? data) {
    if (data == null) return;

    _namaController.text = data['nama'] ?? '';
    _usernameController.text = data['username'] ?? '';
    _emailController.text = data['email'] ?? '';
    _institusiController.text = data['sekolah'] ?? '';

    if (data['tanggalLahir'] != null) {
      _selectedDate = (data['tanggalLahir'] as Timestamp).toDate();
      _tanggalLahirController.text = DateFormat('d MMMM yyyy').format(_selectedDate!);
    }
  }

  void _cancelEdit(Map<String, dynamic>? data) {
    setState(() {
      _isEditing = false;
      _loadToControllers(data);
    });
  }

  Future<void> _saveProfile(AuthProvider auth) async {
    await auth.updateProfile(
      nama: _namaController.text.trim(),
      username: _usernameController.text.trim(),
      sekolah: _institusiController.text.trim(),
      tanggalLahir: _selectedDate,
    );

    if (mounted) {
      setState(() => _isEditing = false);
      showTopOverlay(context, 'Perubahan Tersimpan');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = DateFormat('d MMMM yyyy').format(picked);
      });
    }
  }

  // --- LOGIKA UPLOAD GAMBAR BARU ---
  Future<void> _pickAndUploadImage(AuthProvider auth) async {
    final picker = ImagePicker();
    // 1. Pilih Gambar dari Galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return; // User membatalkan

    setState(() => _isUploadingImage = true);

    try {
      final File file = File(image.path);
      final String fileName = 'avatar_${auth.user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. Upload ke Supabase (Bucket: avatars)
      // Pastikan kamu sudah buat bucket bernama 'avatars' di Supabase dashboard
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, file);

      // 3. Ambil Public URL
      final String publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // 4. Update URL ke Firestore via Provider
      await auth.updateProfilePhoto(publicUrl);

      if (mounted) {
        showTopOverlay(context, 'Foto profil diperbarui');
      }

    } catch (e) {
      debugPrint("Error upload: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal upload gambar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userData = auth.userProfile;

    return userData == null
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : _buildUI(auth, userData);
  }

  Widget _buildUI(AuthProvider auth, Map<String, dynamic> data) {
    const double blueHeaderHeight = 152.0;
    const double avatarTopPosition = 82.0;
    const double avatarOuterRadius = 50.0; // Sedikit diperbesar
    const double avatarInnerRadius = 46.0;

    // Cek apakah user punya foto profil
    String? photoUrl = data['photoUrl'];
    String inisial = (data['nama'] != null && data['nama'].isNotEmpty)
        ? data['nama'][0].toUpperCase()
        : "U";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            Column(children: [Container(height: blueHeaderHeight, width: double.infinity, decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight,
                  colors: [Color(0xFF4FA0FF), Color(0xFF2A7EFF), Color(0xFF165EFC)]),
            ))]),

            Column(
              children: [
                const SizedBox(height: avatarTopPosition),

                GestureDetector(
                  onTap: _isEditing ? () => _pickAndUploadImage(auth) : null, // Hanya bisa klik saat mode Edit aktif
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: avatarOuterRadius,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: avatarInnerRadius,
                          backgroundColor: const Color(0xFF2782FF),
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : null,
                          child: (photoUrl == null || photoUrl.isEmpty)
                              ? Text(
                            inisial,
                            style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                              : null,
                        ),
                      ),

                      if (_isUploadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          ),
                        ),

                      if (_isEditing && !_isUploadingImage)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.camera_alt, color: Color(0xFF2782FF), size: 20),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Text(data['nama'] ?? 'Pengguna', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6E7E96))),
                const SizedBox(height: 2),
                Text('@${data['username'] ?? '-'}', style: TextStyle(fontSize: 16, color: const Color(0xFF6E7E96).withOpacity(0.9))),
                const SizedBox(height: 14),

                _isEditing
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _saveProfile(auth),
                      icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                      label: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF28A745),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => _cancelEdit(data),
                      icon: Icon(Icons.close, color: Colors.grey.shade700),
                      label: Text('Batal', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfileStatColumn(
                        value: auth.isLoadingStats ? "..." : auth.totalCatatan.toString(),
                        label: 'Catatan'
                    ),
                    const SizedBox(width: 40),
                    ProfileStatColumn(
                        value: auth.isLoadingStats ? "..." : auth.totalSuka.toString(),
                        label: 'Suka'
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                ProfileTabSelector(controller: _tabController),

                const SizedBox(height: 14),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _tabController.index == 0
                        ? _isEditing
                        ? ProfileEditForm(
                      namaController: _namaController,
                      usernameController: _usernameController,
                      tanggalLahirController: _tanggalLahirController,
                      institusiController: _institusiController,
                      onDateTap: () => _selectDate(context),
                    )
                        : ProfileAboutView(
                      userData: data,
                      onEditPressed: () => setState(() => _isEditing = true),
                    )
                        : _tabController.index == 1
                        ? const ProfileNotesTab()
                        : const ProfileSettingsTab(),
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
}