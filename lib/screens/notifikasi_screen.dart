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
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: Column(
        children: [
          // header
          Container(
            width: double.infinity,
            color: const Color(0xFF2782FF),
            child: const AppHeader(showSearchBar: false),
          ),

          // daftar notifikasi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("Belum ada notifikasi"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final notifDoc = docs[index];
                    final notif = notifDoc.data() as Map<String, dynamic>;
                    final String actorId = notif['actorId'];

                    final timestamp = notif['timestamp']?.toDate() ?? DateTime.now();

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

                        final String name = userData?['name'] ?? "User";
                        final String? photoUrl = userData?['photoUrl'];

                        return NotificationItem(
                          initial: name.isNotEmpty ? name[0].toUpperCase() : "?",
                          message: notif['message'] ?? "",
                          time: formatTime(timestamp),
                          isNew: notif['isNew'] ?? false,
                          profileUrl: photoUrl,
                          notificationId: notifDoc.id, // penting untuk markAsRead
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
