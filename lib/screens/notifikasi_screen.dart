import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/notification_item.dart';
import '../widgets/app_header.dart';
import '../utils/time_formatter.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Silakan login terlebih dahulu")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: const Color(0xFF2782FF),
            child: const AppHeader(showSearchBar: false),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Notifikasi",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Daftar Notifikasi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.hasError) {
                  return const Center(child: Text("Gagal memuat notifikasi"));
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("Belum ada notifikasi"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 5, bottom: 80),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final notifDoc = docs[index];
                    final notif = notifDoc.data() as Map<String, dynamic>;

                    final String actorId = notif['actorId'] ?? "";
                    final timestamp = notif['timestamp']?.toDate() ?? DateTime.now();

                    if (actorId.isEmpty) {
                      return NotificationItem(
                        initial: "?",
                        message: notif['message'] ?? "",
                        time: formatTime(timestamp),
                        isNew: notif['isNew'] ?? false,
                        profileUrl: null,
                        notificationId: notifDoc.id,
                      );
                    }

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(actorId)
                          .get(),
                      builder: (context, userSnap) {
                        if (!userSnap.hasData) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: const SizedBox(height: 50, width: 50,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                          );
                        }

                        final userData = userSnap.data!.data() as Map<String, dynamic>?;

                        String rawName = userData?['username'] ?? userData?['nama'] ?? "Seseorang";

                        String displayName = rawName;
                        if (displayName.contains('@') && displayName.contains('.')) {
                          displayName = displayName.split('@')[0];
                        }

                        if (displayName != "Seseorang" && !displayName.startsWith('@')) {
                          displayName = "@$displayName";
                        }

                        final String rawMsg = notif['message'] ?? "";
                        final String fullMessage = "$displayName $rawMsg";

                        final String? photoUrl = userData?['photoUrl'];

                        String initial = "?";
                        if (displayName.length > 1) {
                          initial = displayName[1].toUpperCase();
                        }

                        return NotificationItem(
                          initial: initial,
                          message: fullMessage,
                          time: formatTime(timestamp),
                          isNew: notif['isNew'] ?? false,
                          profileUrl: photoUrl,
                          notificationId: notifDoc.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}