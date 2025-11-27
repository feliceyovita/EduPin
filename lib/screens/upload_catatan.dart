import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/catatan_provider.dart';
import '../widgets/section_card.dart';

class UploadCatatanScreen extends StatefulWidget {
  const UploadCatatanScreen({super.key});

  @override
  State<UploadCatatanScreen> createState() => _UploadCatatanScreenState();
}

class _UploadCatatanScreenState extends State<UploadCatatanScreen> {
  // =========================
  // CONTROLLERS & VARIABLES
  // =========================
  final _titleC = TextEditingController();
  final _descC = TextEditingController();
  final _schoolC = TextEditingController();
  final _tagInputC = TextEditingController();

  List<File> _selectedImages = [];
  String? _selectedSubject;
  String? _selectedGrade;

  List<String> _tags = [];
  bool _publikasi = true;
  bool _izinkanUnduh = true;

  final List<String> _grades = [
    "SD",
    "SMP",
    "SMA",
    "Kuliah",
    "lanjutan"
  ];

  List<String> _subjects = [
    "Matematika dan Komputasi",
    "Ilmu Pengetahuan Alam",
    "Ilmu Sosial",
    "Seni dan Desain",
    "Pendidikan dan Pengembangan Diri",
    "Teknik dan Rekayasa",
    "Hukum dan Regulasi",
  ];

  List<String> _schoolList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _schoolC.dispose();
    _tagInputC.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedImages.isNotEmpty &&
        _titleC.text.trim().isNotEmpty &&
        _descC.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedGrade != null &&
        _tags.isNotEmpty;
  }

  // =========================
  // PICK IMAGE
  // =========================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    setState(() {
      _selectedImages.add(File(xfile.path));
    });
  }

  // =========================
  // SUBMIT
  // =========================
  Future<void> _onSubmit() async {
    if (!_isFormValid) return;

    final provider = context.read<NotesProvider>();

    // Loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await provider.uploadNote(
      imageAssets: _selectedImages,
      title: _titleC.text.trim(),
      description: _descC.text.trim(),
      subject: _selectedSubject!,
      grade: _selectedGrade!,
      school: _schoolC.text.trim(),
      tags: _tags,
      publikasi: _publikasi,
      izinkanUnduh: _izinkanUnduh,
    );


    if (mounted) {
      Navigator.pop(context); // tutup loading
      context.pop(); // kembali
    }
  }

  // =========================
  // TAG HANDLER
  // =========================
  void _addTag() {
    final t = _tagInputC.text.trim();
    if (t.isEmpty) return;
    if (!_tags.contains(t)) {
      setState(() => _tags.add(t));
    }
    _tagInputC.clear();
  }

  // =========================
  // BUILD UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;
    final horizontalPad = isWide ? size.width * 0.15 : 16.0;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB3BECD), width: 1),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
    );

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
          padding: EdgeInsets.fromLTRB(horizontalPad, 16, horizontalPad, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(), // Bagian yang sudah diedit jadi tengah
              const SizedBox(height: 16),
              SectionCard(
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
                        prefixIcon: const Icon(Icons.notes_outlined,
                            color: Color(0xFF2563EB)),
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
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: border,
                        enabledBorder: border,
                        focusedBorder: focusBorder,
                        hintText: 'Pilih mata pelajaran',
                      ),
                      value: _selectedSubject,
                      items: _subjects
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSubject = v),
                    ),
                    const SizedBox(height: 12),

                    // GRADE
                    const Text('Tingkat / Kelas *',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: border,
                        enabledBorder: border,
                        focusedBorder: focusBorder,
                        hintText: 'Pilih tingkat / kelas',
                      ),
                      value: _selectedGrade,
                      items: _grades
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedGrade = v),
                    ),
                    const SizedBox(height: 12),

                    // SCHOOL AUTOCOMPLETE
                    const Text('Asal Sekolah / Universitas (opsional)',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _schoolList.where((s) => s
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        controller.text = _schoolC.text;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Nama Sekolah/Universitas',
                            border: border,
                            enabledBorder: border,
                            focusedBorder: focusBorder,
                          ),
                        );
                      },
                      onSelected: (selection) => _schoolC.text = selection,
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
                            .map((t) => Chip(
                          label: Text(t),
                          onDeleted: () =>
                              setState(() => _tags.remove(t)),
                        ))
                            .toList(),
                      )
                    else
                      const Text(
                        'Minimal 1 tag untuk catatanmu',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
              ),
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

  // =========================
  // IMAGE PICKER (SUDAH DI EDIT JADI TENGAH)
  // =========================
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // <-- Diubah jadi center
      children: [
        const Text("Gambar Catatan *", style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        Wrap(
          alignment: WrapAlignment.center, // <-- Ditambahkan alignment center
          spacing: 8,
          runSpacing: 8,
          children: [
            // button pick image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                  color: Colors.white,
                ),
                child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
              ),
            ),

            // loop gambar
            for (var img in _selectedImages)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(img, width: 120, height: 120, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedImages.remove(img));
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
          ],
        )
      ],
    );
  }


  // =========================
  // PUBLISH SETTINGS
  // =========================
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
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged)
        ],
      ),
    );
  }

  // =========================
  // SUBMIT BUTTON
  // =========================
  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _isFormValid ? _onSubmit : null,
      icon: const Icon(Icons.share_rounded),
      label: const Text('Publikasikan Catatan'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}