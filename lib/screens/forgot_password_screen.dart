import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/logoApp_bgBlue.dart';
import '../widgets/text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxContentWidth = 400.0;
        final double horizontalPadding = constraints.maxWidth > maxContentWidth
            ? (constraints.maxWidth - maxContentWidth) / 2
            : constraints.maxWidth * 0.08;

        final double effectiveWidth =
        constraints.maxWidth > maxContentWidth ? maxContentWidth : constraints.maxWidth;

        final double titleFontSize = effectiveWidth * 0.08;
        final double subtitleFontSize = effectiveWidth * 0.035;
        final double cardTitleFontSize = effectiveWidth * 0.06;
        final double labelFontSize = effectiveWidth * 0.05;

        final double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FD),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: () {
                context.go('/login');
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ),
          extendBodyBehindAppBar: true,

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: appBarHeight),

                        // Logo & Title
                        const logoAppBgBlue(),
                        const SizedBox(height: 16),
                        Text(
                          'EduPin',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Platform Berbagi Catatan Pelajaran',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Card
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
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: cardTitleFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  'Masukkan email Anda dan kami akan \n mengirim link untuk reset password',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              Text(
                                'Email',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: labelFontSize * 0.8,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // TextField dengan controller
                              textField(
                                controller: emailController,
                                hintText: 'Masukkan email terdaftar anda',
                                prefixIcon: Icons.email_outlined,
                              ),

                              const SizedBox(height: 24),
                              Text(
                                'Pastikan email yang Anda masukkan adalah email yang terdaftar di akun EduPin',
                                style: TextStyle(
                                  fontSize: subtitleFontSize * 0.9,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final email = emailController.text.trim();

                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Email tidak boleh kosong'),
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(email: email);

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Link reset password telah dikirim!'),
                                        ),
                                      );

                                      context.go('/login');
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Gagal mengirim reset password: $e'),
                                        ),
                                      );
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
                                        colors: [
                                          Color(0xFF2196F3),
                                          Color(0xFF42A5F5),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Kirim link reset password',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
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
                        const SizedBox(height: 40),
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