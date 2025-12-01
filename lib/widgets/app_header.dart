import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final Function(String)? onSearchChanged;
  final TextEditingController? searchController;
  final String hintText;
  final bool showSearchBar;

  final Widget? customTitle;

  const AppHeader({
    super.key,
    this.onSearchChanged,
    this.searchController,
    this.hintText = "Cari...",
    this.showSearchBar = true,
    this.customTitle, // Tambahkan di constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 45,
        bottom: 20,
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
          customTitle ??
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

          // 2. SEARCH BAR
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
                onChanged: onSearchChanged,
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