class LengthLogic {
  // Conversion factors relative to Feet
  static const double feetPerInch = 1.0 / 12.0;
  static const double feetPerMeter = 3.28084;
  static const double feetPerKm = 3280.84;
  static const double feetPerNauticalMile = 6076.12; // 1852 meters
  static const double feetPerMile = 5280.0;
  static const double feetPerYard = 3.0; // গজ
  static const double feetPerHaat = 1.5; // হাত

  // New units relative to Meter
  static const double meterPerHm = 100.0;
  static const double meterPerDam = 10.0;
  static const double meterPerDm = 0.1;
  static const double meterPerCm = 0.01;
  static const double meterPerMm = 0.001;

  static Map<String, double> convert(double value, String fromUnit) {
    double feet = 0;

    // Convert input to feet
    switch (fromUnit) {
      case 'feet': feet = value; break;
      case 'inch': feet = value * feetPerInch; break;
      case 'meter': feet = value * feetPerMeter; break;
      case 'km': feet = value * feetPerKm; break;
      case 'nautical_mile': feet = value * feetPerNauticalMile; break;
      case 'mile': feet = value * feetPerMile; break;
      case 'yard': feet = value * feetPerYard; break;
      case 'haat': feet = value * feetPerHaat; break;
      case 'hm': feet = value * meterPerHm * feetPerMeter; break;
      case 'dam': feet = value * meterPerDam * feetPerMeter; break;
      case 'dm': feet = value * meterPerDm * feetPerMeter; break;
      case 'cm': feet = value * meterPerCm * feetPerMeter; break;
      case 'mm': feet = value * meterPerMm * feetPerMeter; break;
    }

    // Convert feet to all other units
    return {
      'nautical_mile': feet / feetPerNauticalMile,
      'mile': feet / feetPerMile,
      'km': feet / feetPerKm,
      'hm': feet / (meterPerHm * feetPerMeter),
      'dam': feet / (meterPerDam * feetPerMeter),
      'meter': feet / feetPerMeter,
      'yard': feet / feetPerYard,
      'haat': feet / feetPerHaat,
      'feet': feet,
      'dm': feet / (meterPerDm * feetPerMeter),
      'inch': feet / feetPerInch,
      'cm': feet / (meterPerCm * feetPerMeter),
      'mm': feet / (meterPerMm * feetPerMeter),
    };
  }
}
