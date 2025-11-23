import 'package:flutter/material.dart';

class PapanScreen extends StatefulWidget {
  const PapanScreen({super.key});

  @override
  State<PapanScreen> createState() => _PapanScreenState();
}

class _PapanScreenState extends State<PapanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // -------- HEADER --------
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: Colors.blue,
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 45), // jarak status bar iOS/Android

                  // Judul + Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 36,
                          height: 36,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "EduPin",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Search Bar
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
                            hintText: "Cari Papan",
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // -------- GRID PAPAN --------
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPapanCard(),
                childCount: 1, // sementara 1, nanti bisa dinamiskan
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPapanCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // <-- ini bikin tengah
      children: [
        // GAMBAR KOTAK FULL
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/sample_note.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Materi UTS",
          textAlign: TextAlign.center, // <-- biar text bener2 di tengah
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "1 pin",
          textAlign: TextAlign.center, // <-- juga di tengah
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
