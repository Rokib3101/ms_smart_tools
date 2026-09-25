import 'package:flutter/material.dart';

class ScannerPageNavigation extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const ScannerPageNavigation({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final isFirst = currentIndex <= 0;
    final isLast = currentIndex >= totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: isFirst ? null : onPrevious,
            color: isFirst ? Colors.grey : Colors.deepPurple,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${currentIndex + 1} / $totalPages',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: isLast ? null : onNext,
            color: isLast ? Colors.grey : Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}
