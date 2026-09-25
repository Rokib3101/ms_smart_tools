class LandLogic {
  // Conversion factors relative to Square Feet (sqft)
  static const double sqftPerDecimal = 435.6;
  static const double sqftPerKatha = 720.0;
  static const double sqftPerBigha = 14400.0;
  static const double sqftPerAcre = 43560.0;
  static const double sqftPerAre = 1076.39; // 1 Are = 100 sqm
  static const double sqftPerHectare = 107639.1; // 1 Hectare = 10,000 sqm
  static const double sqftPerSqm = 10.7639;

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
      case 'kani': sqft = value * (kaniDecimal * sqftPerDecimal); break;
    }

    // Convert sqft to all other units
    return {
      'sqft': sqft,
      'decimal': sqft / sqftPerDecimal,
      'katha': sqft / sqftPerKatha,
      'bigha': sqft / sqftPerBigha,
      'acre': sqft / sqftPerAcre,
      'are': sqft / sqftPerAre,
      'hectare': sqft / sqftPerHectare,
      'sqm': sqft / sqftPerSqm,
    };
  }

  // Legacy methods kept for compatibility or simplified if needed
  static Map<String, double> convertFromDecimal(double decimals) => convert(decimals, 'decimal');
  static Map<String, double> convertFromSqft(double sqft) => convert(sqft, 'sqft');
  static Map<String, double> convertFromKatha(double katha) => convert(katha, 'katha');
  static Map<String, double> convertFromBigha(double bigha) => convert(bigha, 'bigha');
  static Map<String, double> convertFromAcre(double acre) => convert(acre, 'acre');
}
