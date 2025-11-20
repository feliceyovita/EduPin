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
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxContentWidth = 400.0;

        // Hitung padding horizontal agar konten berada di tengah pada layar lebar
        final double horizontalPadding = constraints.maxWidth > maxContentWidth
            ? (constraints.maxWidth - maxContentWidth) / 2
            : constraints.maxWidth * 0.08;

        // Gunakan lebar efektif untuk perhitungan ukuran font yang adaptif
        final double effectiveWidth =
        constraints.maxWidth > maxContentWidth ? maxContentWidth : constraints.maxWidth;

        final double titleFontSize = effectiveWidth * 0.08;
        final double subtitleFontSize = effectiveWidth * 0.035;
        final double cardTitleFontSize = effectiveWidth * 0.06;
        final double labelFontSize = effectiveWidth * 0.05;

        // Tinggi AppBar + Status Bar
        final double appBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;


        return Scaffold(
          backgroundColor: const Color(0xFFF4F8FD),
          // Menggunakan AppBar kembali untuk tombol fixed
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
          // PENTING: Memperluas body di belakang AppBar agar konten dapat digulir hingga ke atas
          extendBodyBehindAppBar: true,

          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxContentWidth, // Batasi lebar maksimum konten
                    minHeight: constraints.maxHeight, // Biarkan konten mengisi seluruh tinggi
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // PENTING: Tambahkan padding di atas untuk memastikan konten tidak tertutup oleh AppBar yang transparan
                        SizedBox(height: appBarHeight),

                        // Konten Utama
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
                              const textField(
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