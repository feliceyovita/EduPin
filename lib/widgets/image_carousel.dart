import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> assets;
  const ImageCarousel({super.key, required this.assets});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final controller = PageController();
  int index = 0;

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Column(
      children: [
        ClipRRect(
          borderRadius: radius,
          child: AspectRatio(
            aspectRatio: 4/3,
            child: PageView.builder(
              controller: controller,
              onPageChanged: (i) => setState(() => index = i),
              itemCount: widget.assets.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: InteractiveViewer(
                            maxScale: 5,
                            child: Image.network(widget.assets[i]),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    widget.assets[i],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  ),
                ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (widget.assets.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.assets.length, (i) {
              final active = i == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? Colors.black54 : Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
      ],
    );
  }
}
