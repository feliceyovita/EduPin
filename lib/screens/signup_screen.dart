import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/logoApp_bgBlue.dart';
import '../widgets/text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxContentWidth = 400.0;

        final double horizontalPadding = constraints.maxWidth > maxContentWidth ? (constraints.maxWidth - maxContentWidth) / 2 : constraints.maxWidth * 0.06;
        final double effectiveWidth = constraints.maxWidth > maxContentWidth ? maxContentWidth : constraints.maxWidth;

        final double titleFontSize = effectiveWidth * 0.08;
        final double subtitleFontSize = 16.0;
        final double cardTextFontSize = effectiveWidth * 0.035;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FD),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxContentWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: constraints.maxHeight * 0.06 < 40
                                ? 40
                                : constraints.maxHeight * 0.06),
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
                        Text(
                          'Platform Berbagi Catatan Pelajaran',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Card utama
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
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
                                  style: TextStyle(
                                    fontSize: cardTextFontSize,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Username
                              Text(
                                'Username',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 6),
                              const textField(
                                hintText: 'Masukkan username',
                                prefixIcon: Icons.person_2_outlined,
                              ),
                              const SizedBox(height: 20),

                              // Nama Lengkap
                              Text(
                                'Nama Lengkap',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 6),
                              const textField(
                                hintText: 'Masukkan nama lengkap',
                                prefixIcon: Icons.person_2_outlined,
                              ),
                              const SizedBox(height: 20),

                              // Email
                              Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const textField(
                                hintText: 'Masukkan email anda',
                                prefixIcon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 20),

                              // Sekolah / universitas
                              Text(
                                'Sekolah/Universitas',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const textField(
                                hintText: 'Nama sekolah / universitas',
                                prefixIcon: Icons.school_outlined,
                              ),
                              const SizedBox(height: 20),

                              // Password
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const textField(
                                hintText: 'Masukkan password anda',
                                obscureText: true,
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: Icons.visibility_off_outlined,
                              ),
                              const SizedBox(height: 20),

                              // Konfirmasi Password
                              Text(
                                'Konfirmasi Password',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const textField(
                                hintText: 'Konfirmasi password',
                                obscureText: true,
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: Icons.visibility_off_outlined,
                              ),
                              const SizedBox(height: 40),

                              // Checkbox persetujuan
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StatefulBuilder(
                                    builder: (context, setState) {
                                      bool isChecked = false;
                                      return Checkbox(
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isChecked = value ?? false;
                                          });
                                        },
                                        activeColor: const Color(0xFF1E88E5),
                                      );
                                    },
                                  ),
                                  const Expanded(
                                    child: Wrap(
                                      children: [
                                        Text(
                                          'Saya setuju dengan ',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          'Syarat dan Ketentuan ',
                                          style: TextStyle(
                                            color: Color(0xFF1E88E5),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'serta ',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        Text(
                                          'Kebijakan Privasi ',
                                          style: TextStyle(
                                            color: Color(0xFF1E88E5),
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'EduPin',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Tombol daftar
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.go('/login');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ).copyWith(
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    elevation: WidgetStateProperty.all(0),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF2196F3),
                                          Color(0xFF42A5F5),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Daftar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Punya akun
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sudah punya akun? ',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.go('/login');
                                    },
                                    child: const Text(
                                      'Masuk Sekarang',
                                      style: TextStyle(
                                        color: Color(0xFF1E88E5),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height: constraints.maxHeight * 0.06 < 40
                                ? 40
                                : constraints.maxHeight * 0.06),
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
}