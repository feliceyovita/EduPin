import 'package:flutter/material.dart';
import 'buttom_sheet.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 2) {
          showUploadSheet(context);
          return;
        }
        onTap(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Papan",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_circle,
            color: Colors.blue,
          ),
          label: "Unggah",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none_outlined),
          label: "Notifikasi",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2_outlined),
          label: "Profil",
        ),
      ],
    );
  }
}
