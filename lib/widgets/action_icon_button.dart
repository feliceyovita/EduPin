import 'package:flutter/material.dart';

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool? toggled;
  const ActionIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.toggled,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = toggled ?? false;
    final theme = Theme.of(context);

    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      style: ButtonStyle(
        // ⬜ latar putih + border abu
        backgroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isOn
                  ? theme.colorScheme.primary // warna garis kalau aktif
                  : Colors.grey.shade400, // warna garis kalau nonaktif
              width: 1.4,
            ),
          ),
        ),
        // efek bayangan kecil biar terasa "naik"
        elevation: WidgetStateProperty.all(0),
        overlayColor: WidgetStateProperty.all(
          theme.colorScheme.primary.withOpacity(.08),
        ),
      ),
      icon: Icon(
        icon,
        color: isOn
            ? theme.colorScheme.primary
            : Colors.grey.shade800, // warna ikon
      ),
    );
  }
}
