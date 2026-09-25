import 'package:flutter/material.dart';

class ScannerCropOverlay extends CustomPainter {
  final List<Offset> corners; // 4 normalized corners [top-left, top-right, bottom-right, bottom-left]
  final Size displaySize;
  final int activeHandleIndex;

  ScannerCropOverlay({
    required this.corners,
    required this.displaySize,
    this.activeHandleIndex = -1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (corners.length != 4) return;

    final width = displaySize.width;
    final height = displaySize.height;

    final p0 = Offset(corners[0].dx * width, corners[0].dy * height);
    final p1 = Offset(corners[1].dx * width, corners[1].dy * height);
    final p2 = Offset(corners[2].dx * width, corners[2].dy * height);
    final p3 = Offset(corners[3].dx * width, corners[3].dy * height);

    final polyPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    // 1. Draw dimmed mask outside document polygon
    final fullRectPath = Path()..addRect(Rect.fromLTWH(0, 0, width, height));
    final dimPath = Path.combine(PathOperation.difference, fullRectPath, polyPath);

    final dimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dimPath, dimPaint);

    // 2. Draw border line connecting the 4 corners
    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(polyPath, linePaint);

    // 3. Draw corner handles
    final points = [p0, p1, p2, p3];
    for (int i = 0; i < points.length; i++) {
      final isSelected = (i == activeHandleIndex);
      final pt = points[i];

      // Inner white circle
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pt, isSelected ? 12.0 : 9.0, innerPaint);

      // Outer ring
      final ringPaint = Paint()
        ..color = isSelected ? Colors.deepOrange : Colors.cyan
        ..strokeWidth = isSelected ? 3.5 : 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pt, isSelected ? 12.0 : 9.0, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScannerCropOverlay oldDelegate) {
    return oldDelegate.corners != corners ||
        oldDelegate.displaySize != displaySize ||
        oldDelegate.activeHandleIndex != activeHandleIndex;
  }
}
