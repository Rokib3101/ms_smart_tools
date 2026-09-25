import 'dart:ui';
import 'scanner_filter_type.dart';

class ScannerPageModel {
  final String id;
  final String originalImagePath;
  List<Offset> corners; // 4 normalized corners [top-left, top-right, bottom-right, bottom-left]
  int rotationAngle; // 0, 90, 180, 270 degrees
  ScannerFilterType selectedFilter;
  bool isDetected;

  ScannerPageModel({
    required this.id,
    required this.originalImagePath,
    required this.corners,
    this.rotationAngle = 0,
    this.selectedFilter = ScannerFilterType.auto,
    this.isDetected = false,
  });

  ScannerPageModel copyWith({
    List<Offset>? corners,
    int? rotationAngle,
    ScannerFilterType? selectedFilter,
    bool? isDetected,
  }) {
    return ScannerPageModel(
      id: id,
      originalImagePath: originalImagePath,
      corners: corners ?? List.from(this.corners),
      rotationAngle: rotationAngle ?? this.rotationAngle,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isDetected: isDetected ?? this.isDetected,
    );
  }
}
