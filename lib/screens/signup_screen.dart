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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF4F8FD),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),
                const logoAppBgBlue(),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'EduPin',
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Platform Berbagi Catatan Pelajaran',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),

                // Card utama
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.04),
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
                        child:Text(
                          'Buat akun baru untuk mulai berbagi catatan!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Nama Lengkap
                      Text(
                        'Nama Lengkap',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 6),
                      textField(
                        hintText: 'Masukkan nama lengkap',
                        prefixIcon: Icons.person_2_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Email
                      Text(
                        'Email',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 6),
                      textField(
                        hintText: 'Masukkan email anda',
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      // sekolah / universitas
                      Text(
                        'Sekolah/Universitas',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 6),
                      textField(
                        hintText: 'Nama sekolah / universitas',
                        prefixIcon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      Text(
                        'Password',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 6),
                      textField(
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
                            color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 6),
                      textField(
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
                                activeColor: Color(0xFF1E88E5),
                              );
                            },
                          ),
                          Expanded(
                            child: Wrap(
                              children: [
                                const Text(
                                  'Saya setuju dengan ',
                                  style: TextStyle(fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // bagian mengarahkan ke syarat dan ketentuan
                                  },
                                  child: const Text(
                                    'Syarat dan Ketentuan ',
                                    style: TextStyle(
                                      color: Color(0xFF1E88E5),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'serta ',
                                  style: TextStyle(fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // bagian mengarahkan ke kebijakan dan privasi
                                  },
                                  child: const Text(
                                    'Kebijakan Privasi ',
                                    style: TextStyle(
                                      color: Color(0xFF1E88E5),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'EduPin',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),


                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.065,
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
                            backgroundColor:
                            WidgetStateProperty.all(Colors.transparent),
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
                            child: Center(
                              child: Text(
                                'Daftar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Daftar
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
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
