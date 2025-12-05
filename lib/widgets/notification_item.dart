import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String initial;
  final String message;
  final String time;
  final bool isNew;

  const NotificationItem({
    super.key,
    required this.initial,
    required this.message,
    required this.time,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Love icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: Color(0xFF2782FF),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // LOVE icon di kanan bawah avatar
              Positioned(
                right: -4,
                bottom: -3,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Teks message + waktu di kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight, // waktu rata kanan
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

