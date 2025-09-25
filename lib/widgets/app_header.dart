import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40), // biar ada jarak dari atas
        Image.asset(
          "assets/images/logo.png",
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 12),
        const Text(
          "EduPin",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
