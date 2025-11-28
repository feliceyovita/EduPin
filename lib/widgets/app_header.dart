import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final Function(String)? onSearchChanged;
  final TextEditingController? searchController;
  final String hintText;
  final bool showSearchBar;

  const AppHeader({
    super.key,
    this.onSearchChanged,
    this.searchController,
    this.hintText = "Cari...",
    this.showSearchBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 45, // Jarak status bar
        bottom: 15,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: 28,
                height: 28,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.school, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                "EduPin",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // 2. SEARCH BAR (KONDISIONAL)
          if (showSearchBar) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged, // Lempar input ke parent
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey.shade600),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}