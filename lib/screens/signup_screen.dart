import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../provider/auth_provider.dart';
import '../widgets/logoApp_bgBlue.dart';
import '../widgets/text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isChecked = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    emailController.dispose();
    schoolController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxContentWidth = 400.0;
        final double horizontalPadding = constraints.maxWidth > maxContentWidth
            ? (constraints.maxWidth - maxContentWidth) / 2
            : constraints.maxWidth * 0.06;

        final double effectiveWidth = constraints.maxWidth > maxContentWidth
            ? maxContentWidth
            : constraints.maxWidth;

        final double titleFontSize = effectiveWidth * 0.08;
        const double subtitleFontSize = 16.0;
        final double cardTextFontSize = effectiveWidth * 0.035;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FD),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxContentWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * 0.06 < 40
                              ? 40
                              : constraints.maxHeight * 0.06,
                        ),
                        const logoAppBgBlue(),
                        const SizedBox(height: 16),
                        Text(
                          'EduPin',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Platform Berbagi Catatan Pelajaran',
                          style: TextStyle(fontSize: subtitleFontSize),
                        ),
                        const SizedBox(height: 30),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 9,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Buat akun baru untuk mulai berbagi catatan!',
                                  style: TextStyle(fontSize: cardTextFontSize),
                                ),
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Username'),
                              textField(
                                controller: usernameController,
                                hintText: 'Masukkan username',
                                prefixIcon: Icons.person_2_outlined,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Nama Lengkap'),
                              textField(
                                controller: nameController,
                                hintText: 'Masukkan nama lengkap',
                                prefixIcon: Icons.person_2_outlined,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Email'),
                              textField(
                                controller: emailController,
                                hintText: 'Masukkan email anda',
                                prefixIcon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Sekolah/Universitas'),
                              textField(
                                controller: schoolController,
                                hintText: 'Nama sekolah / universitas',
                                prefixIcon: Icons.school_outlined,
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Password'),
                              textField(
                                controller: passwordController,
                                hintText: 'Masukkan password anda',
                                prefixIcon: Icons.lock_outline,
                                obscureText: !showPassword,
                                suffixIcon: showPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                onSuffixTap: () => setState(() => showPassword = !showPassword),
                              ),
                              const SizedBox(height: 20),

                              _buildLabel('Konfirmasi Password'),
                              textField(
                                controller: confirmPasswordController,
                                hintText: 'Konfirmasi password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: !showConfirmPassword,
                                suffixIcon: showConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                onSuffixTap: () => setState(() => showConfirmPassword = !showConfirmPassword),
                              ),
                              const SizedBox(height: 30),

                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (v) => setState(() => isChecked = v!),
                                    activeColor: const Color(0xFF1E88E5),
                                  ),
                                  Expanded(
                                    child: RichText(
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(text: 'Saya setuju dengan ', style: TextStyle(color: Colors.black)),
                                          TextSpan(text: 'Syarat dan Ketentuan ', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                                          TextSpan(text: 'serta ', style: TextStyle(color: Colors.black)),
                                          TextSpan(text: 'Kebijakan Privasi ', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
                                          TextSpan(text: 'EduPin', style: TextStyle(color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (!isChecked) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Harap setujui syarat dan ketentuan')),
                                      );
                                      return;
                                    }
                                    if (passwordController.text != confirmPasswordController.text) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Password dan konfirmasi tidak sama')),
                                      );
                                      return;
                                    }

                                    final authProvider = context.read<AuthProvider>();

                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const Center(child: CircularProgressIndicator()),
                                    );

                                    final success = await authProvider.signUpWithEmail(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      displayName: nameController.text.trim(),
                                    );

                                    if (context.mounted) Navigator.pop(context);

                                    if (success) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(authProvider.user!.uid)
                                            .set({
                                          'id': authProvider.user!.uid,
                                          'username': usernameController.text.trim(),
                                          'nama': nameController.text.trim(),
                                          'sekolah': schoolController.text.trim(),
                                          'email': emailController.text.trim(),
                                          'createdAt': FieldValue.serverTimestamp(),
                                        });

                                        if (context.mounted) {
                                          context.go('/login');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Berhasil membuat akun')),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Gagal menyimpan data: $e')),
                                          );
                                        }
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(authProvider.errorMessage ?? 'Gagal mendaftar')),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ).copyWith(
                                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                    elevation: WidgetStateProperty.all(0),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Daftar',
                                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Sudah punya akun?', style: TextStyle(color: Colors.grey[700])),
                                  GestureDetector(
                                    onTap: () => context.go('/login'),
                                    child: const Text(
                                      ' Masuk sekarang',
                                      style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w500));
}
