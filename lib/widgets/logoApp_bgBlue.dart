import 'package:flutter/material.dart';

class logoAppBgBlue extends StatelessWidget {
  const logoAppBgBlue({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: Color(0xFF2782FF), // background biru
        borderRadius: BorderRadius.circular(20), // sudut membulat
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png', // ganti sesuai nama ikonmu
          width: 46,
          height: 46,
        ),
      ),
    );
  }
}
