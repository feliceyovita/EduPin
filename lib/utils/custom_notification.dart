import 'package:flutter/material.dart';

OverlayEntry? _overlayEntry;

void showTopOverlay(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2), bool isError = false}) {

  removeOverlay();

  final overlay = Overlay.of(context, rootOverlay: true);
  if (overlay == null) return;
  _overlayEntry = OverlayEntry(
    builder: (context) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: isError ? Colors.red.shade600 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: removeOverlay,
                    child:
                    const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(_overlayEntry!);

  Future.delayed(duration, () {
    removeOverlay();
  });
}

void removeOverlay() {
  if (_overlayEntry != null) {
    _overlayEntry!.remove();
    _overlayEntry = null;
  }
}