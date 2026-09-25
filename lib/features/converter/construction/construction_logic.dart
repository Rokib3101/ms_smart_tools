class ConstructionLogic {
  static Map<String, double> estimateBricks({
    required double lengthFt,
    required double heightFt,
    double wallThicknessInch = 5.0,
  }) {
    double area = lengthFt * heightFt;
    // Standard BD estimation:
    // 5" wall: 5 bricks per sq.ft
    // 10" wall: 10 bricks per sq.ft
    double factor = wallThicknessInch > 5 ? 10.0 : 5.0;
    double totalBricks = area * factor;

    // Cement & Sand (simplified for 5" wall per 100 sq.ft)
    // Approx: 1.5 bags cement and 8 cft sand per 100 sq.ft (5" wall)
    double cementBags = (area / 100) * 1.5;
    double sandCft = (area / 100) * 8.0;

    return {
      'bricks': totalBricks,
      'cement': cementBags,
      'sand': sandCft,
    };
  }
}
