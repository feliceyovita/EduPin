import 'package:flutter/material.dart';
import '../models/note_details.dart';
import '../services/catatan_service.dart';
import '../widgets/app_header.dart';
import '../widgets/pin_card.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? filterData; // untuk terima data dari detail tag/kategori

  const HomeScreen({super.key, this.filterData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategoryIndex = 0;
  String searchQuery = "";
  bool isTagFilter = false; // untuk menandai filter berdasarkan tag
  final TextEditingController _searchController = TextEditingController();

  List<String> categories = ["Semua"];

  @override
  void initState() {
    super.initState();
    if (widget.filterData != null) {
      _applyFilter(widget.filterData!);
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterData != oldWidget.filterData && widget.filterData != null) {
      _applyFilter(widget.filterData!);
    }
  }

  void _applyFilter(Map<String, dynamic> filter) {
    final type = filter["type"];
    final value = filter["value"];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (type == "category") {
        filterByCategory(value);
      } else if (type == "tag") {
        filterByTag(value);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          searchController: _searchController,
          hintText: "Cari catatan, mata pelajaran...",
          onSearchChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
              isTagFilter = false; // reset flag tag saat search manual
            });
          },
        ),
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

                  final filtered = _applyFilters(notes);

                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      // ================= CATEGORY MENU =================
                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: categories.length,
                          itemBuilder: (_, i) {
                            final isSelected = i == selectedCategoryIndex;
                            return GestureDetector(
                              onTap: () {
                                filterByCategory(categories[i]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2782FF) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF2782FF)),
                                ),
                                child: Text(
                                  categories[i],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF2782FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // ================= CONTENT =================
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const double minWidth = 200;
                              int cols = (constraints.maxWidth / minWidth).floor();
                              cols = cols.clamp(2, 5);

                              return filtered.isEmpty
                                  ? const Center(
                                child: Text("Belum ada catatan publik."),
                              )
                                  : GridView.builder(
                                itemCount: filtered.length,
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  mainAxisExtent: 370,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemBuilder: (_, i) => PinCard(
                                  data: filtered[i],
                                  onCategoryTap: filterByCategory,
                                  onTagTap: filterByTag,
                                ),
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

  // ================= LOGIC FILTER =================
  void filterByCategory(String subject) {
    setState(() {
      selectedCategoryIndex = categories.indexOf(subject);
      searchQuery = "";
      _searchController.text = "";
      isTagFilter = false; // reset tag filter
    });
  }

  void filterByTag(String tag) {
    setState(() {
      searchQuery = tag.toLowerCase();
      _searchController.text = tag;
      selectedCategoryIndex = 0;
      isTagFilter = true; // aktifkan flag tag
    });
  }

  void _updateCategoryList(List<NoteDetail> notes) {
    final subjects = notes.map((n) => n.subject.trim()).toSet().toList();
    categories = ["Semua", ...subjects];
  }

  List<NoteDetail> _applyFilters(List<NoteDetail> notes) {
    var result = notes.where((n) => n.publikasi == true).toList();

    // filter berdasarkan kategori
    if (selectedCategoryIndex != 0 && !isTagFilter) {
      result = result
          .where((n) => n.subject == categories[selectedCategoryIndex])
          .toList();
    }

    // filter berdasarkan search bar
    if (searchQuery.isNotEmpty) {
      if (isTagFilter) {
        // cuma filter berdasarkan tag yang sama
        result = result
            .where((n) =>
            n.tags.any((tag) => tag.toLowerCase() == searchQuery))
            .toList();
      } else {
        // filter biasa search bar
        result = result
            .where((n) =>
        n.title.toLowerCase().contains(searchQuery) ||
            n.subject.toLowerCase().contains(searchQuery) ||
            n.tags.any((tag) => tag.toLowerCase().contains(searchQuery)))
            .toList();
      }
    }

    return result;
  }
}
