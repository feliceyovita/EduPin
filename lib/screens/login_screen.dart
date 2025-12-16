import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../utils/custom_notification.dart';
import '../widgets/logoApp_bgBlue.dart';
import '../widgets/text_field.dart';
import '../utils/validators.dart';
import '../provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final emailError = Validators.validateEmail(email);
    if (emailError != null) {showTopOverlay(context, emailError, isError: true,);
      return;
    }

    final passError = Validators.validatePassword(password);
    if (passError != null) {showTopOverlay(context, passError, isError: true,);
      return;
    }

    // Proses Login
    final success = await authProvider.signInWithEmail(
      email: email,
      password: password,
    );

    if (success) {showTopOverlay(context, 'Login berhasil!', isError: false,);
      context.go('/home'); // pastikan route ada
    } else {showTopOverlay(context, authProvider.errorMessage ?? 'Login gagal', isError: true,);
    }

  }
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxContentWidth = 400.0;
        final double horizontalPadding =
        constraints.maxWidth > maxContentWidth
            ? (constraints.maxWidth - maxContentWidth) / 2
            : constraints.maxWidth * 0.08;
        final double effectiveWidth =
        constraints.maxWidth > maxContentWidth
            ? maxContentWidth
            : constraints.maxWidth;
        final double titleFontSize = effectiveWidth * 0.08;
        final double subtitleFontSize = effectiveWidth * 0.035;
        final double cardTitleFontSize = effectiveWidth * 0.06;

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * 0.1 < 60
                              ? 60
                              : constraints.maxHeight * 0.1,
                        ),
                        const logoAppBgBlue(),
                        const SizedBox(height: 16),
                        Text(
                          'EduPin',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2782FF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Platform Berbagi Catatan Pelajaran',
                          style: TextStyle(fontSize: subtitleFontSize),
                        ),
                        const SizedBox(height: 30),

                        // Card utama
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
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
                                  'Selamat Datang',
                                  style: TextStyle(
                                    fontSize: cardTitleFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Center(
                                child: Text(
                                  'Masuk ke akun anda untuk melanjutkan',
                                  style: TextStyle(fontSize: subtitleFontSize),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Email
                              // Email
                              const Text(
                                'Email',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan email anda',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: Colors.grey.shade100, // samain
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: const Color(0xFF2782FF)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

// Password
                              const Text(
                                'Password',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: passwordController,
                                obscureText: !isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan password anda',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100, // samain
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: const Color(0xFF2782FF)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    context.go('/forgot_password');
                                  },
                                  child: const Text(
                                    'Lupa Password?',
                                    style:
                                    TextStyle(color: Color(0xFF2A7EFF)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Tombol Masuk
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed:
                                  isLoading ? null : () => _handleLogin(context),
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
                                          Color(0xFF2782FF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: isLoading
                                          ? const CircularProgressIndicator()
                                          : const Text(
                                        'Masuk',
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

                              // atau
                              Center(child: Text('atau')),

                              const SizedBox(height: 20),

                              // Daftar
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Belum punya akun? '),
                                  GestureDetector(
                                    onTap: () {
                                      context.go('/signup');
                                    },
                                    child: const Text(
                                      'Daftar Sekarang',
                                      style: TextStyle(
                                        color: const Color(0xFF2782FF),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: constraints.maxHeight * 0.06 < 30
                              ? 30
                              : constraints.maxHeight * 0.06,
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
}
