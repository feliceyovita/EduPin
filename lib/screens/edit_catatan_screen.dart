import 'dart:io'; // Import untuk File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_details.dart';
import '../widgets/section_card.dart';

class EditCatatanScreen extends StatefulWidget {
  final NoteDetail note;
  const EditCatatanScreen({super.key, required this.note});

  @override
  State<EditCatatanScreen> createState() => _EditCatatanScreenState();
}

class _EditCatatanScreenState extends State<EditCatatanScreen> {
  // ---------- CONTROLLER & STATE ----------
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _schoolC = TextEditingController();
  final _tagInputC = TextEditingController();

  String? _selectedSubject;
  String? _selectedGrade;
  final List<String> _tags = [];

  bool _publikasi = true;
  bool _izinkanUnduh = true;

  String? _currentImageUrl;
  bool _isUploading = false;
  bool _isSaving = false;

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
    return _currentImageUrl != null &&
        _titleC.text.trim().isNotEmpty &&
        _descC.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedGrade != null &&
        _tags.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    final note = widget.note;

    _titleC.text = note.title;
    _descC.text = note.description;
    _schoolC.text = note.school ?? "";
    _selectedSubject = _subjects.contains(note.subject) ? note.subject : null;
    _selectedGrade = _grades.contains(note.grade) ? note.grade : null;
    _tags.addAll(note.tags);
    _publikasi = note.publikasi;
    _izinkanUnduh = note.izinkanUnduh;

    if (note.imageAssets.isNotEmpty) {
      _currentImageUrl = note.imageAssets[0];
    }

    _titleC.addListener(_onFormChange);
    _descC.addListener(_onFormChange);
    _schoolC.addListener(_onFormChange);
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _schoolC.dispose();
    _tagInputC.dispose();
    super.dispose();
  }

  void _onFormChange() => setState(() {});

  void _onAddTag() {
    final text = _tagInputC.text.trim();
    if (text.isEmpty) return;
    if (!_tags.contains(text)) {
      setState(() {
        _tags.add(text);
      });
    }
    _tagInputC.clear();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final File file = File(image.path);
      final String fileName = 'note_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('image_catatan')
          .upload(fileName, file);

      final String publicUrl = Supabase.instance.client.storage
          .from('image_catatan')
          .getPublicUrl(fileName);

      setState(() {
        _currentImageUrl = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar berhasil diunggah!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      debugPrint("Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _onSaveChanges() async {
    if (!_isFormValid) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('notes').doc(widget.note.id).update({
        'title': _titleC.text.trim(),
        'description': _descC.text.trim(),
        'subject': _selectedSubject,
        'grade': _selectedGrade,
        'school': _schoolC.text.trim(),
        'tags': _tags,
        'publikasi': _publikasi,
        'izinkanUnduh': _izinkanUnduh,
        'imageAssets': _currentImageUrl != null ? [_currentImageUrl] : [],
        'imageUrl': _currentImageUrl, // Update juga field legacy jika ada
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text('Edit Catatan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPad,
                16,
                horizontalPad,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePreview(),
                      const SizedBox(width: 16),
                      _buildAddImageButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMainFormCard(),
                  const SizedBox(height: 16),
                  _buildPublishSettingsCard(),
                  const SizedBox(height: 16),
                  _buildSaveChangesButton(),
                  const SizedBox(height: 4),
                  const Text(
                    'Dengan mengunggah, Anda setuju dengan kebijakan Komunitas EduPin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: GestureDetector(
        onTap: _isUploading ? null : _pickAndUploadImage,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                  ? NetworkImage(_currentImageUrl!)
                  : const AssetImage('assets/images/sample_note.jpeg') as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
          child: _isUploading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(height: 8),
                Text(
                  'Ganti Gambar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5F5), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.blue,
              size: 36,
            ),
            SizedBox(height: 8),
            Text(
              'Ganti Gambar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFormCard() {
    final OutlineInputBorder _inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFB3BECD), width: 1),
    );

    final OutlineInputBorder _focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
    );

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Judul Catatan *',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _titleC,
            decoration: InputDecoration(
              hintText: 'Contoh: Rumus Integral dan Penerapannya',
              prefixIcon: const Icon(
                Icons.notes_outlined,
                color: Color(0xFF2563EB),
              ),
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: _focusBorder,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Deskripsi *',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _descC,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
              'Jelaskan isi catatan, materi yang dibahas, atau tips belajar...',
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: _focusBorder,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Mata Pelajaran *',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            decoration: InputDecoration(
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: _focusBorder,
              hintText: 'Pilih mata pelajaran',
            ),
            items: _subjects
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) => setState(() {
              _selectedSubject = value;
            }),
          ),
          const SizedBox(height: 12),

          const Text(
            'Tingkat/Kelas *',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedGrade,
            decoration: InputDecoration(
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: _focusBorder,
              hintText: 'Pilih tingkat / kelas',
            ),
            items: _grades
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (value) => setState(() {
              _selectedGrade = value;
            }),
          ),
          const SizedBox(height: 12),

          const Text(
            'Asal Sekolah/Universitas (opsional)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _schoolC,
            decoration: InputDecoration(
              hintText: 'Nama Sekolah/Universitas',
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: _focusBorder,
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'Tags *',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagInputC,
                  decoration: InputDecoration(
                    hintText: 'Tambah tag...',
                    prefixIcon: const Icon(
                      Icons.tag_outlined,
                      color: Color(0xFF2563EB),
                    ),
                    border: _inputBorder,
                    enabledBorder: _inputBorder,
                    focusedBorder: _focusBorder,
                  ),
                  onSubmitted: (_) => _onAddTag(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                width: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _onAddTag,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags
                  .map(
                    (t) => Chip(
                  label: Text(t),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(t);
                    });
                  },
                ),
              )
                  .toList(),
            )
          else
            const Text(
              'Minimal 1 tag untuk membantu pengguna lain menemukan catatanmu.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  // ---------- CARD PENGATURAN PUBLIKASI ----------
  Widget _buildPublishSettingsCard() {
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan Publikasi',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                _buildPublishRow(
                  icon: Icons.remove_red_eye_outlined,
                  title: 'Publikasi',
                  subtitle: 'Catatan dapat dilihat oleh semua pengguna.',
                  value: _publikasi,
                  onChanged: (val) => setState(() => _publikasi = val),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
                ),
                _buildPublishRow(
                  icon: Icons.download_outlined,
                  title: 'Izinkan Mengunduh',
                  subtitle: 'Pengguna dapat mengunduh gambar catatan.',
                  value: _izinkanUnduh,
                  onChanged: (val) => setState(() => _izinkanUnduh = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFE0ECFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  // ---------- TOMBOL SIMPAN ----------
  Widget _buildSaveChangesButton() {
    final bool isEnabled = _isFormValid && !_isUploading && !_isSaving;

    const gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: [0.20, 0.61],
      colors: [
        Color(0xFF009EF7),
        Color(0xFF2583FF),
      ],
    );

    final textStyle = const TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    const iconColor = Colors.white;

    final disabledTextStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white.withOpacity(0.8),
    );
    final disabledIconColor = Colors.white.withOpacity(0.8);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isEnabled ? gradient : null,
        color: isEnabled ? null : Colors.grey.shade400,
        borderRadius: const BorderRadius.all(Radius.circular(100)),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isEnabled ? _onSaveChanges : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaving)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                else
                  Icon(
                    Icons.save_outlined,
                    color: isEnabled ? iconColor : disabledIconColor,
                  ),
                const SizedBox(width: 8),
                Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                  style: isEnabled ? textStyle : disabledTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}