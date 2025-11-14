import 'package:flutter/material.dart';

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});
  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

class ProfileStatColumn extends StatelessWidget {
  final String value;
  final String label;
  const ProfileStatColumn({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final Widget iconWidget;
  final String text;
  const ProfileInfoRow({super.key, required this.iconWidget, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 15),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF333333), fontWeight: FontWeight.w500))),
      ],
    );
  }
}

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  const ProfileTextField({super.key, required this.controller, required this.label, this.readOnly = false, this.onTap, this.suffixIcon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        const SizedBox(height: 5),
        TextField(
          controller: controller, readOnly: readOnly, onTap: onTap,
          decoration: InputDecoration(
            fillColor: Colors.white, filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class ProfileTabSelector extends StatefulWidget {
  final TabController controller;
  const ProfileTabSelector({super.key, required this.controller});

  @override
  State<ProfileTabSelector> createState() => _ProfileTabSelectorState();
}

class _ProfileTabSelectorState extends State<ProfileTabSelector> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          Alignment alignment;
          switch (widget.controller.index) {
            case 0:
              alignment = Alignment.centerLeft;
              break;
            case 1:
              alignment = Alignment.center;
              break;
            default:
              alignment = Alignment.centerRight;
          }

          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: alignment,
                child: Container(
                  width: constraints.maxWidth / 3,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF4FF),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildTextTabItem(0, 'Tentang'),
                  _buildTextTabItem(1, 'Catatan'),
                  _buildTextTabItem(2, 'Pengaturan'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextTabItem(int index, String label) {
    final bool isSelected = widget.controller.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.controller.animateTo(index),
        child: Container(
          height: 38,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF2782FF) : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}