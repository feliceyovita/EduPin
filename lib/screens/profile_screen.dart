import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import paket intl untuk format tanggal

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late TabController _tabController;

  final _namaController = TextEditingController(text: "Sari Kurnia");
  final _usernameController = TextEditingController(text: "sarikurnia");
  final _emailController = TextEditingController(text: "sari.kurnia@gmail.com");
  final _institusiController = TextEditingController(text: "Universitas Sumatera Utara");

  // Controller dan state untuk tanggal lahir
  final _tanggalLahirController = TextEditingController(text: "15 Mei 2003");
  DateTime? _selectedDate = DateTime(2003, 5, 15);

  OverlayEntry? _overlayEntry; // untuk menyimpan overlay saat ditampilkan

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Inisialisasi locale untuk format tanggal Indonesia
    Intl.defaultLocale = 'id_ID';
  }

  @override
  void dispose() {
    _removeOverlayIfAny();
    _tabController.dispose();
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _institusiController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    _showTopOverlay('Perubahan Tersimpan!');
    _toggleEdit();
  }

  // Helper untuk menampilkan overlay toast di atas layar
  void _showTopOverlay(String message, {Duration duration = const Duration(seconds: 2)}) {
    // pastikan kita tidak menumpuk overlay
    _removeOverlayIfAny();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final topPadding = MediaQuery.of(context).viewPadding.top + 8.0;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: topPadding,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // optional: tombol close manual
                    GestureDetector(
                      onTap: _removeOverlayIfAny,
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);

    // Hapus overlay otomatis setelah durasi
    Future.delayed(duration, () {
      _removeOverlayIfAny();
    });
  }

  void _removeOverlayIfAny() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (_) {}
      _overlayEntry = null;
    }
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'), // Set locale date picker ke Indonesia
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = DateFormat('d MMMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9), // Warna background utama
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // --- PERUBAHAN: Column utama untuk semua konten ---
            Column(
              children: [
                // Header gradient, sekarang hanya sebagai background
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                      colors: [
                        Color(0xFF4FA0FF), // 0%
                        Color(0xFF2A7EFF), // 50%
                        Color(0xFF165EFC), // 100%
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Konten di bawah header, untuk memastikan SingleChildScrollView tahu total tinggi halaman
                const SizedBox(height: 450),
              ],
            ),

            // --- PERUBAHAN: Konten profil sekarang diletakkan di atas background ---
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFF2782FF),
                      child: Text('SK', style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Nama dan Username
                  Text(_namaController.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6E7E96))),
                  const SizedBox(height: 2),
                  Text('@${_usernameController.text}', style: TextStyle(fontSize: 16, color: const Color(0xFF6E7E96).withOpacity(0.9))),
                  const SizedBox(height: 14),

                  // Menampilkan stats atau tombol edit
                  _isEditing ? _buildEditButtons() : _buildStats(),

                  const SizedBox(height: 14),

                  // Kartu putih dengan tab
                  _buildTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan stats
  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatColumn('24', 'Catatan'),
        const SizedBox(width: 40),
        _buildStatColumn('156', 'Suka'),
      ],
    );
  }

  // Widget untuk menampilkan tombol Simpan dan Batal
  Widget _buildEditButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tombol Simpan
        ElevatedButton.icon(
          onPressed: _saveProfile,
          icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
          label: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF28A745),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
          ),
        ),
        const SizedBox(width: 16),
        // Tombol Batal
        OutlinedButton.icon(
          onPressed: _toggleEdit,
          icon: Icon(Icons.close, color: Colors.grey.shade700, size: 20),
          label: Text('Batal', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade400, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
          ),
        ),
      ],
    );
  }


  Widget _buildTabContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF333333),
            unselectedLabelColor: Colors.grey,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.0, color: Color(0xFF2782FF)),
              insets: EdgeInsets.symmetric(horizontal: 40.0),
            ),
            tabs: const [
              Tab(text: 'Tentang'),
              Tab(text: 'Catatan'),
              Tab(text: 'Pengaturan'),
            ],
          ),
          SizedBox(
            height: 420,
            child: TabBarView(
              controller: _tabController,
              children: [
                _isEditing ? _buildEditProfileForm() : _buildAboutSection(),
                const Center(child: Text('Konten Catatan')),
                const Center(child: Text('KontEN Pengaturan')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Informasi Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                ElevatedButton.icon(
                  onPressed: _toggleEdit,
                  icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                  label: const Text('Edit Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            _buildInfoRow(Icons.email_outlined, _emailController.text),
            const SizedBox(height: 18),
            _buildInfoRow(Icons.calendar_today_outlined, _tanggalLahirController.text),
            const SizedBox(height: 18),
            _buildInfoRow(Icons.school_outlined, _institusiController.text),
            const SizedBox(height: 18),
            _buildInfoRow(Icons.location_on_outlined, 'Medan, Indonesia'),
            const SizedBox(height: 18),
            _buildInfoRow(Icons.access_time_outlined, 'Bergabung September 2025'),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
            const Divider(height: 30),
            _buildTextField(_namaController, 'Nama Lengkap'),
            const SizedBox(height: 15),
            _buildTextField(_usernameController, 'Username'),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tanggal Lahir', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                const SizedBox(height: 5),

                // --- INI ADALAH PERBAIKANNYA ---
                // Membungkus TextField dengan Builder untuk mendapatkan context baru
                Builder(
                    builder: (BuildContext builderContext) { // 'builderContext' adalah context yang valid
                      return TextField(
                        controller: _tanggalLahirController,
                        readOnly: true,
                        onTap: () => _selectDate(builderContext), // Gunakan context baru
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                      );
                    }
                ),
                // --- AKHIR PERBAIKAN ---

              ],
            ),
            const SizedBox(height: 15),
            _buildTextField(_institusiController, 'Institusi'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(width: 15),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF333333), fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
        ),
      ],
    );
  }
}