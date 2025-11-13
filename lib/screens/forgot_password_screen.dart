import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/logoApp_bgBlue.dart';
import '../widgets/text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            context.go('/login');
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
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
                SizedBox(height: screenHeight * 0.02),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04,
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
                          'Reset Password',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Center(
                        child: Text(
                          'Masukkan email Anda dan kami akan \n mengirim link untuk reset password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),

                      Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.05,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 6),
                      textField(
                        hintText: 'Masukkan email terdaftar anda',
                        prefixIcon: Icons.email_outlined,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Text(
                        'Pastikan email yang Anda masukkan adalah email yang terdaftar di akun EduPin',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

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
                                'Kirim link reset password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
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
