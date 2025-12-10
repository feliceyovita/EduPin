import 'package:intl/intl.dart';

String formatTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inSeconds < 60) return "baru saja";
  if (diff.inMinutes < 60) return "${diff.inMinutes} menit yang lalu";
  if (diff.inHours < 24) return "${diff.inHours} jam yang lalu";
  if (diff.inDays < 7) return "${diff.inDays} hari yang lalu";

  return DateFormat("dd/MM/yyyy").format(time);
}
