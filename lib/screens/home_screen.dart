import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/list_kategori.dart';
import '../widgets/pin_card.dart';
import '../data/dummy_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.blue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppHeader(),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Cari catatan, mata pelajaran...",
                        border: InputBorder.none,
                        icon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // 🟦 Scaffold tetap dipakai, tapi padding atas DIHAPUS
        Expanded(
          child: Scaffold(
            backgroundColor: const Color(0xFFF0F5F9),
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true, // 👈 HILANGKAN JARAK ATAS

              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        ListKategori(
                          selectedIndex: selectedCategory,
                          onSelected: (index) {
                            setState(() => selectedCategory = index);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const double minCardWidth = 180;
                          int crossAxisCount =
                          (constraints.maxWidth / minCardWidth).floor();

                          if (crossAxisCount < 2) crossAxisCount = 2;
                          if (crossAxisCount > 5) crossAxisCount = 5;

                          return GridView.builder(
                            itemCount: dummyNotes.length,
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisExtent: 350,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemBuilder: (_, index) =>
                                PinCard(data: dummyNotes[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
