import 'package:edupin/screens/profile_tabs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/profile_widgets.dart';
import '../utils/custom_notification.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late TabController _tabController;

  final Map<String, dynamic> _userData = {
    "nama": "Sari Kurnia",
    "username": "sarikurnia",
    "email": "sari.kurnia@gmail.com",
    "institusi": "Universitas Sumatera Utara",
    "tanggalLahir": DateTime(2003, 5, 15),
    "bergabung": "Bergabung September 2025",
    "catatanCount": "24",
    "sukaCount": "156",
  };

  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _institusiController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Intl.defaultLocale = 'id_ID';
    _loadUserDataToControllers();

    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _institusiController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  void _loadUserDataToControllers() {
    _namaController.text = _userData['nama'];
    _usernameController.text = _userData['username'];
    _emailController.text = _userData['email'];
    _institusiController.text = _userData['institusi'];
    _selectedDate = _userData['tanggalLahir'];
    if (_selectedDate != null) {
      _tanggalLahirController.text = DateFormat('d MMMM yyyy').format(_selectedDate!);
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _loadUserDataToControllers();
    });
  }

  void _saveProfile() {
    setState(() {
      _userData['nama'] = _namaController.text;
      _userData['username'] = _usernameController.text;
      _userData['institusi'] = _institusiController.text;
      _userData['tanggalLahir'] = _selectedDate;
      _isEditing = false;
    });
    showTopOverlay(context, 'Perubahan Tersimpan!');
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _loadUserDataToControllers();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
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
    const double blueHeaderHeight = 152.0;
    const double avatarTopPosition = 82.0;
    const double avatarOuterRadius = 46.0;
    const double avatarInnerRadius = 43.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: blueHeaderHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.topRight,
                      colors: [Color(0xFF4FA0FF), Color(0xFF2A7EFF), Color(0xFF165EFC)],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const SizedBox(height: avatarTopPosition),
                CircleAvatar(
                  radius: avatarOuterRadius,
                  backgroundColor: Colors.white,
                  child: const CircleAvatar(
                    radius: avatarInnerRadius,
                    backgroundColor: Color(0xFF2782FF),
                    child: Text('SK', style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_userData['nama'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6E7E96))),
                const SizedBox(height: 2),
                Text('@${_userData['username']}', style: TextStyle(fontSize: 16, color: const Color(0xFF6E7E96).withOpacity(0.9))),
                const SizedBox(height: 14),

                _isEditing ? _buildEditButtons() : _buildStats(),

                const SizedBox(height: 14),

                _buildTabContent(),

                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileStatColumn(value: _userData['catatanCount'], label: 'Catatan'),
        const SizedBox(width: 40),
        ProfileStatColumn(value: _userData['sukaCount'], label: 'Suka'),
      ],
    );
  }

  Widget _buildEditButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _saveProfile,
          icon: const Icon(Icons.save_outlined, color: Colors.white, size: 20),
          label: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF28A745), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: _cancelEdit,
          icon: Icon(Icons.close, color: Colors.grey.shade700, size: 20),
          label: Text('Batal', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.grey.shade700, side: BorderSide(color: Colors.grey.shade400, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        ProfileTabSelector(controller: _tabController),
        const SizedBox(height: 14),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Container(
              key: ValueKey<int>(_tabController.index),
              child: _buildCurrentTab(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTab() {
    switch (_tabController.index) {
      case 0:
        return _isEditing
            ? ProfileEditForm(
          namaController: _namaController,
          usernameController: _usernameController,
          tanggalLahirController: _tanggalLahirController,
          institusiController: _institusiController,
          onDateTap: () => _selectDate(context),
        )
            : ProfileAboutView(
          userData: _userData,
          onEditPressed: _toggleEdit,
        );
      case 1:
        return const ProfileNotesTab();
      case 2:
        return const ProfileSettingsTab();
      default:
        return Container();
    }
  }
}