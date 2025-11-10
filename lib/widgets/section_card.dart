import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  const SectionCard({super.key, required this.child, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? const EdgeInsets.all(16);
    final mar = margin ?? const EdgeInsets.symmetric(vertical: 6);

    final radius = BorderRadius.circular(18);

    return Container(
      margin: mar,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(3, 0)),
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(-3, 0)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(padding: pad, child: child),
      ),
    );
  }
}