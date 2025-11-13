import 'package:flutter/material.dart';

class AppNavBar extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;

  const AppNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Cari",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_circle,
            color: Colors.blue,
          ),
          label: "Unggah",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.push_pin_outlined),
          label: "Pin",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_2_outlined),
          label: "Profil",
        ),
      ],
    );
  }
}
