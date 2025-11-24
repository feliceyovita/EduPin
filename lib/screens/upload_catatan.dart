import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/section_card.dart';

class UploadCatatanScreen extends StatefulWidget {
  const UploadCatatanScreen({super.key});

  @override
  State<UploadCatatanScreen> createState() => _UploadCatatanScreenState();
}

class _UploadCatatanScreenState extends State<UploadCatatanScreen> {
  // ---------- CONTROLLER ----------
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _schoolC = TextEditingController();
  final _tagInputC = TextEditingController();

  // ---------- STATE ----------
  File? _selectedImage;
  String? _selectedSubject;
  String? _selectedGrade;
  final List<String> _tags = [];

  bool _publikasi = true;
  bool _izinkanUnduh = true;

  // ---------- DATA DROPDOWN ----------
  static const _subjects = [
    'Matematika dan Komputasi',
    'Ilmu Pengetahuan Alam',
    'Ilmu Sosial',
    'Seni dan Desain',
    'Pendidikan dan Pengembangan Diri',
    'Teknik dan Rekayasa',
    'Hukum dan Regulasi',
  ];

  static const _grades = [
    'Sekolah Dasar (SD)',
    'Sekolah Menengah Pertama (SMP)',
    'Sekolah Menengah Atas (SMA)',
    'Kuliah',
    'Lanjutan',
  ];

  // ---------- VALIDASI ----------
  bool get _isFormValid {
    return _selectedImage != null &&
        _titleC.text.trim().isNotEmpty &&
        _descC.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedGrade != null &&
        _tags.isNotEmpty;
  }

  // ---------- IMAGE PICKER ----------
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  // ---------- UPLOAD IMAGE TO FIREBASE STORAGE ----------
  Future<String> _uploadImage(File file) async {
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
    final ref = FirebaseStorage.instance.ref().child("notes/$fileName");

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ---------- SUBMIT DATA ----------
  Future<void> _onSubmit() async {
    if (!_isFormValid) return;

    try {
      // 1. UPLOAD IMAGE
      final imageUrl = await _uploadImage(_selectedImage!);

      // 2. SAVE TO FIRESTORE
      await FirebaseFirestore.instance.collection("notes").add({
        "title": _titleC.text.trim(),
        "description": _descC.text.trim(),
        "subject": _selectedSubject,
        "grade": _selectedGrade,
        "school": _schoolC.text.trim(),
        "tags": _tags,
        "publikasi": _publikasi,
        "izinkanUnduh": _izinkanUnduh,
        "imageUrl": imageUrl,
        "createdAt": Timestamp.now(),
        "authorId": FirebaseAuth.instance.currentUser!.uid,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Catatan berhasil dipublikasikan!")
          ),
        );
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;
    final horizontalPad = isWide ? size.width * 0.15 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF6FF),
        elevation: 0,
        centerTitle: true,
        title: const Text('Tambah Catatan Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPad,
            16,
            horizontalPad,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 16),
              _buildMainFormCard(),
              const SizedBox(height: 16),
              _buildPublishSettingsCard(),
              const SizedBox(height: 16),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // UI BUILDERS (TIDAK DIUBAH KECUALI BAGIAN GAMBAR)
  // =====================================================================

  Widget _buildImagePicker() {
    final hasImage = _selectedImage != null;

    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasImage ? Colors.blue : const Color(0xFFCBD5F5),
              width: 1.5,
            ),
          ),
          child: hasImage
              ? ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
          )
              : const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, color: Colors.blue),
              SizedBox(height: 8),
              Text('Maks 10MB\nper Gambar',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainFormCard() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB3BECD), width: 1),
    );

    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
    );

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          const Text('Judul Catatan *',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleC,
            decoration: InputDecoration(
              hintText: 'Contoh: Rumus Integral dan Penerapannya',
              prefixIcon:
              const Icon(Icons.notes_outlined, color: Color(0xFF2563EB)),
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
            ),
          ),
          const SizedBox(height: 12),

          // DESCRIPTION
          const Text('Deskripsi *',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _descC,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Jelaskan isi catatan...',
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
            ),
          ),
          const SizedBox(height: 12),

          // SUBJECT
          const Text('Mata Pelajaran *',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField(
            decoration: InputDecoration(
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
            ),
            items: _subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _selectedSubject = v),
            hint: const Text('Pilih mata pelajaran'),
          ),
          const SizedBox(height: 12),

          // GRADE
          const Text('Tingkat / Kelas *',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField(
            decoration: InputDecoration(
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
            ),
            items: _grades
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _selectedGrade = v),
            hint: const Text('Pilih tingkat / kelas'),
          ),
          const SizedBox(height: 12),

          // SCHOOL OPTIONAL
          const Text('Asal Sekolah / Universitas (opsional)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _schoolC,
            decoration: InputDecoration(
              hintText: 'Nama Sekolah/Universitas',
              border: border,
              enabledBorder: border,
              focusedBorder: focusBorder,
            ),
          ),
          const SizedBox(height: 12),

          // TAGS
          const Text('Tags *',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagInputC,
                  onSubmitted: (_) => _addTag(),
                  decoration: InputDecoration(
                    hintText: 'Tambah tag...',
                    prefixIcon: const Icon(Icons.tag_outlined,
                        color: Color(0xFF2563EB)),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: focusBorder,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                width: 48,
                child: FilledButton(
                  onPressed: _addTag,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB)),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          if (_tags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: _tags
                  .map(
                    (t) => Chip(
                  label: Text(t),
                  onDeleted: () {
                    setState(() => _tags.remove(t));
                  },
                ),
              )
                  .toList(),
            )
          else
            const Text(
              'Minimal 1 tag',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  void _addTag() {
    final t = _tagInputC.text.trim();
    if (t.isEmpty) return;
    if (!_tags.contains(t)) {
      setState(() => _tags.add(t));
    }
    _tagInputC.clear();
  }

  Widget _buildPublishSettingsCard() {
    return SectionCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSwitchRow(
            icon: Icons.visibility_outlined,
            title: "Publikasi",
            subtitle: "Catatan dapat dilihat semua orang.",
            value: _publikasi,
            onChanged: (v) => setState(() => _publikasi = v),
          ),
          const Divider(height: 1),
          _buildSwitchRow(
            icon: Icons.download_outlined,
            title: "Izinkan Unduh",
            subtitle: "Pengguna dapat mengunduh catatan.",
            value: _izinkanUnduh,
            onChanged: (v) => setState(() => _izinkanUnduh = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE0ECFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                    const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged)
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _isFormValid ? _onSubmit : null,
      icon: const Icon(Icons.share_rounded),
      label: const Text('Publikasikan Catatan'),
      style:
      FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
    );
  }
}
