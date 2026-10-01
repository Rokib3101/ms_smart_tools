class LandLogic {
  // Conversion factors relative to Square Feet (sqft)
  static const double sqftPerDecimal = 435.6;
  static const double sqftPerKatha = 720.0;
  static const double sqftPerBigha = 14400.0;
  static const double sqftPerAcre = 43560.0;
  static const double sqftPerAre = 1076.39; // 1 Are = 100 sqm
  static const double sqftPerHectare = 107639.1; // 1 Hectare = 10,000 sqm
  static const double sqftPerSqm = 10.7639;
  static const double sqftPerSqMi = 27878400.0;
  static const double sqftPerSqKm = 10763910.4;
  static const double sqftPerSqYd = 9.0;
  static const double sqftPerSqIn = 1.0 / 144.0;
  static const double sqftPerSqCm = 0.00107639;
  static const double sqftPerSqMm = 0.0000107639;

  static Map<String, double> convert(double value, String fromUnit, {double kaniDecimal = 40.0}) {
    double sqft = 0;

    // First convert input to sqft
    switch (fromUnit) {
      case 'sqft': sqft = value; break;
      case 'decimal': sqft = value * sqftPerDecimal; break;
      case 'katha': sqft = value * sqftPerKatha; break;
      case 'bigha': sqft = value * sqftPerBigha; break;
      case 'acre': sqft = value * sqftPerAcre; break;
      case 'are': sqft = value * sqftPerAre; break;
      case 'hectare': sqft = value * sqftPerHectare; break;
      case 'sqm': sqft = value * sqftPerSqm; break;
      case 'sq_mi': sqft = value * sqftPerSqMi; break;
      case 'sq_km': sqft = value * sqftPerSqKm; break;
      case 'sq_yd': sqft = value * sqftPerSqYd; break;
      case 'sq_in': sqft = value * sqftPerSqIn; break;
      case 'sq_cm': sqft = value * sqftPerSqCm; break;
      case 'sq_mm': sqft = value * sqftPerSqMm; break;
      case 'kani': sqft = value * (kaniDecimal * sqftPerDecimal); break;
    }

    // Convert sqft to all other units (ordered from largest to smallest)
    return {
      'sq_mi': sqft / sqftPerSqMi,
      'sq_km': sqft / sqftPerSqKm,
      'hectare': sqft / sqftPerHectare,
      'acre': sqft / sqftPerAcre,
      'bigha': sqft / sqftPerBigha,
      'are': sqft / sqftPerAre,
      'katha': sqft / sqftPerKatha,
      'decimal': sqft / sqftPerDecimal,
      'sqm': sqft / sqftPerSqm,
      'sq_yd': sqft / sqftPerSqYd,
      'sqft': sqft,
      'sq_in': sqft / sqftPerSqIn,
      'sq_cm': sqft / sqftPerSqCm,
      'sq_mm': sqft / sqftPerSqMm,
    };
  }

  // Legacy methods kept for compatibility or simplified if needed
  static Map<String, double> convertFromDecimal(double decimals) => convert(decimals, 'decimal');
  static Map<String, double> convertFromSqft(double sqft) => convert(sqft, 'sqft');
  static Map<String, double> convertFromKatha(double katha) => convert(katha, 'katha');
  static Map<String, double> convertFromBigha(double bigha) => convert(bigha, 'bigha');
  static Map<String, double> convertFromAcre(double acre) => convert(acre, 'acre');
}
