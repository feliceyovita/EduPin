import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/section_card.dart';

class UploadCatatanScreen extends StatefulWidget {
  const UploadCatatanScreen({super.key});

  @override
  State<UploadCatatanScreen> createState() => _UploadCatatanScreenState();
}

class _UploadCatatanScreenState extends State<UploadCatatanScreen> {
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
  bool _hasImage = false;

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
    return _hasImage &&
        _titleC.text.trim().isNotEmpty &&
        _descC.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedGrade != null &&
        _tags.isNotEmpty; // minimal 1 tag
    // _schoolC boleh kosong (opsional)
  }

  @override
  void initState() {
    super.initState();
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

  void _onPickImage() {
    // nanti ganti pakai image picker / file picker
    setState(() {
      _hasImage = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Dummy: gambar dianggap sudah dipilih (belum terhubung ke storage).',
        ),
      ),
    );
  }

  void _onSubmit() {
    // nanti di sini logic upload ke backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan berhasil dipublikasikan (dummy).'),
      ),
    );
    // setelah submit, bisa pop balik
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;
    final horizontalPad = isWide ? size.width * 0.15 : 16.0;

    final _inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade400),
    );

    final _focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFEFF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF6FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text('Tambah Catatan Baru'),
        // ⬇️ ikon back: balik ke halaman sebelumnya (apa pun itu)
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
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  _buildMainFormCard(),
                  const SizedBox(height: 16),
                  _buildPublishSettingsCard(),
                  const SizedBox(height: 16),
                  _buildSubmitButton(),
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
      // ⬇️ NAVBAR DIHAPUS, jadi fullscreen form
      // bottomNavigationBar: AppNavBar(...),
    );
  }

  // ---------- WIDGET: PICKER GAMBAR ----------
  Widget _buildImagePicker() {
    final borderColor =
    _hasImage ? Colors.blue : const Color(0xFFCBD5F5); // biru muda

    return Center(
      child: GestureDetector(
        onTap: _onPickImage,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _hasImage ? Icons.image_rounded : Icons.cloud_upload_outlined,
                color: Colors.blue,
                size: 36,
              ),
              const SizedBox(height: 8),
              const Text(
                'Maks 10MB\nper Gambar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- CARD UTAMA FORM ----------
  Widget _buildMainFormCard() {
    final OutlineInputBorder _inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB3BECD), width: 1),
    );

    final OutlineInputBorder _focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
    );

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- JUDUL ----------------
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
                color: Color(0xFF2563EB), // biru
              ),
              border: _inputBorder,
              enabledBorder: _inputBorder,
              focusedBorder: _focusBorder,
            ),
          ),
          const SizedBox(height: 12),

          // ---------------- DESKRIPSI ----------------
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

          // ---------------- MATA PELAJARAN ----------------
          const Text(
            'Mata Pelajaran *',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
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

          // ---------------- TINGKAT / KELAS ----------------
          const Text(
            'Tingkat/Kelas *',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedGrade,
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

          // ---------------- SEKOLAH OPSIONAL ----------------
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

          // ---------------- TAGS ----------------
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
                      color: Color(0xFF2563EB), // biru
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
                      borderRadius: BorderRadius.circular(14),
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

  // ---------- TOMBOL SUBMIT ----------
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isFormValid ? _onSubmit : null,
        icon: const Icon(Icons.share_rounded),
        label: const Text('Publikasikan Catatan'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
