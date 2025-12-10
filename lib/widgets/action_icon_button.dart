import 'package:flutter/material.dart';

class ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool? toggled;
  final bool disabled;

  const ActionIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.toggled,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = toggled ?? false;
    final theme = Theme.of(context);

    // jika disabled, kasih warna redup
    final effectiveBorderColor = disabled
        ? Colors.grey.shade300
        : isOn
        ? theme.colorScheme.primary
        : Colors.grey.shade400;

    final effectiveIconColor = disabled
        ? Colors.grey.shade400
        : isOn
        ? theme.colorScheme.primary
        : Colors.grey.shade800;

    return IconButton(
      tooltip: tooltip,
      onPressed: disabled ? null : onTap, // tombol dimatikan
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.white),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: effectiveBorderColor,
              width: 1.4,
            ),
          ),
        ),
        elevation: WidgetStateProperty.all(0),
        overlayColor: WidgetStateProperty.all(
          disabled
              ? Colors.transparent
              : theme.colorScheme.primary.withOpacity(.08),
        ),
      ),
      icon: Icon(
        icon,
        color: effectiveIconColor,
      ),
    );
  }
}
