import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const SectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? const EdgeInsets.all(16);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          // 🔹 Bayangan bawah
          BoxShadow(
            color: Color(0x1A000000), // 10% hitam
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
          // 🔹 Bayangan kanan
          BoxShadow(
            color: Color(0x0F000000), // 6% hitam
            blurRadius: 8,
            offset: Offset(3, 0),
          ),
          // 🔹 Bayangan kiri
          BoxShadow(
            color: Color(0x0F000000), // 6% hitam
            blurRadius: 8,
            offset: Offset(-3, 0),
          ),
        ],
      ),
      child: Padding(padding: pad, child: child),
    );
  }
}
