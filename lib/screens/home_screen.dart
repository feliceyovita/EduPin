import 'package:flutter/material.dart';
import '../models/note_details.dart';
import '../services/catatan_service.dart';
import '../widgets/app_header.dart';
import '../widgets/pin_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  String searchQuery = "";

  List<String> categories = ["Semua"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          hintText: "Cari catatan, mata pelajaran...",
          onSearchChanged: (value) {
            setState(() => searchQuery = value.toLowerCase());
          },
        ),

        // MAIN CONTENT
        Expanded(
          child: Scaffold(
            backgroundColor: const Color(0xFFF0F5F9),
            body: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: StreamBuilder<List<NoteDetail>>(
                stream: NotesService().streamNotes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notes = snapshot.data!;

                  _updateCategoryList(notes);

                  var filtered = _applyFilters(notes);

                  return Column(
                    children: [
                      // CATEGORY FILTER LIST
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: categories.length,
                          itemBuilder: (_, i) {
                            final isSelected = i == selectedCategoryIndex;
                            return GestureDetector(
                              onTap: () => setState(() {
                                selectedCategoryIndex = i;
                              }),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue),
                                ),
                                child: Text(
                                  categories[i],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // DATA DISPLAY GRID
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const double minWidth = 200;
                              int cols = (constraints.maxWidth / minWidth).floor();

                              cols = cols.clamp(2, 5);

                              return GridView.builder(
                                itemCount: filtered.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  mainAxisExtent: 370,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemBuilder: (_, i) => PinCard(data: filtered[i]),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  // Update category list from subjects found
  void _updateCategoryList(List<NoteDetail> notes) {
    final subjects = notes.map((n) => n.subject.trim()).toSet().toList();
    categories = ["Semua", ...subjects];
  }

  // Apply search + category filters
  List<NoteDetail> _applyFilters(List<NoteDetail> notes) {
    var result = notes;

    if (selectedCategoryIndex != 0) {
      result = result.where((n) => n.subject == categories[selectedCategoryIndex]).toList();
    }

    if (searchQuery.isNotEmpty) {
      result = result.where(
            (n) =>
        n.title.toLowerCase().contains(searchQuery) ||
            n.subject.toLowerCase().contains(searchQuery),
      ).toList();
    }

    return result;
  }
}
