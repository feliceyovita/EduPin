import 'package:flutter/material.dart';

class ListKategori extends StatelessWidget {
  final List<String> kategori = const [
    "Semua",
    "Matematika dan Komputasi",
    "Ilmu Pengetahuan Alam",
    "Ilmu Sosial",
    "Seni dan Desain",
    "Pendidikan dan Pengembangan Diri",
    "Teknik dan Rekayasa",
    "Hukum dan Regulasi",
  ];

  final List<IconData> kategoriIcons = const [
    Icons.home_rounded,
    Icons.calculate,
    Icons.science,
    Icons.people,
    Icons.brush,
    Icons.school,
    Icons.engineering,
    Icons.balance,
  ];

  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const ListKategori({
    super.key,
    required this.selectedIndex,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: kategori.length,
        itemBuilder: (context, index) {
          final item = kategori[index];
          final icon = kategoriIcons[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelected?.call(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade400 : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Color(0xFF2782FF)),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : Color(0xFF2782FF),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Color(0xFF2782FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
      ),
    );
  }
}
