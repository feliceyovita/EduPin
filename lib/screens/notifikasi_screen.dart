import 'package:flutter/material.dart';
import '../widgets/notification_item.dart';
import '../widgets/app_header.dart';
import '../widgets/app_navbar.dart';
class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF2782FF),
            child: const AppHeader(showSearchBar: false),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 80),
              children: const [
                NotificationItem(
                  initial: "SK",
                  message: 'Shah Rukh Kan menyukai pin Anda! “Struktur Data Stack dan Queue”',
                  time: "2 menit yang lalu",
                  isNew: true,
                ),
                NotificationItem(
                  initial: "JK",
                  message: 'Just Kidding Rowling dan 99+ pengguna lainnya menyukai catatan anda',
                  time: "1 jam yang lalu",
                ),
                NotificationItem(
                  initial: "JK",
                  message: 'Just Kidding Rowling dan 9 pengguna lainnya menyukai postingan anda',
                  time: "19/09/2025",
                ),
                NotificationItem(
                  initial: "SK",
                  message: 'Anda menambahkan papan baru: Jarkom. Simpan catatan penting di sini!',
                  time: "20/09/2025",
                ),
              ],
            ),
          ),
        ],
      ),
      );
  }
}
