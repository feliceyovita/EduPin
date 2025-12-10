import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationItem extends StatelessWidget {
  final String initial;
  final String message;
  final String time;
  final bool isNew;
  final String? profileUrl;
  final String? notificationId;

  const NotificationItem({
    super.key,
    required this.initial,
    required this.message,
    required this.time,
    this.profileUrl,
    this.isNew = false,
    this.notificationId,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = profileUrl != null && profileUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () async {
        // jika notifikasi baru dan ada id, tandai sudah dibaca
        if (isNew && notificationId != null) {
          final uid = FirebaseAuth.instance.currentUser!.uid;
          await NotificationService().markAsRead(
            targetUserId: uid,
            notificationId: notificationId!,
          );
        }
        // bisa tambahkan navigasi ke detail catatan / papan di sini
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isNew ? const Color(0xFF2782FF) : const Color(0xFFE2E8F0),
            width: isNew ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: hasPhoto
                        ? Image.network(
                      profileUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackAvatar(),
                      loadingBuilder: (context, child, loading) {
                        if (loading == null) return child;
                        return _fallbackAvatar(isLoading: true);
                      },
                    )
                        : _fallbackAvatar(),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.3,),
                      children: [
                        TextSpan(text: message, style: TextStyle(fontWeight: isNew ? FontWeight.w600 : FontWeight.normal,),),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // tetap ada widget di kiri, tapi kosong jika bukan baru
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2782FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text("baru", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600,),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                      Text(time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600,),
                      ),
                    ],
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // fallback avatar UI
  Widget _fallbackAvatar({bool isLoading = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isLoading ? Colors.grey.shade300 : const Color(0xFF2782FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      )
          : Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
