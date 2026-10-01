class LengthLogic {
  // Conversion factors relative to Meter
  static const double metersPerParsec = 3.08567758e16;
  static const double metersPerLightYear = 9.46073e15;
  static const double metersPerAu = 1.495978707e11;
  static const double metersPerNauticalMile = 1852.0;
  static const double metersPerMile = 1609.344;
  static const double metersPerKm = 1000.0;
  static const double metersPerHm = 100.0;
  static const double metersPerDam = 10.0;
  static const double metersPerFathom = 1.8288;
  static const double metersPerMeter = 1.0;
  static const double metersPerYard = 0.9144;
  static const double metersPerHaat = 0.4572;
  static const double metersPerFeet = 0.3048;
  static const double metersPerDm = 0.1;
  static const double metersPerInch = 0.0254;
  static const double metersPerCm = 0.01;
  static const double metersPerMm = 0.001;
  static const double metersPerUm = 1e-6;
  static const double metersPerNm = 1e-9;
  static const double metersPerAngstrom = 1e-10;

  static Map<String, double> convert(double value, String fromUnit) {
    double meters = 0;

    switch (fromUnit) {
      case 'pc': meters = value * metersPerParsec; break;
      case 'ly':
      case 'lv': meters = value * metersPerLightYear; break;
      case 'au': meters = value * metersPerAu; break;
      case 'nautical_mile': meters = value * metersPerNauticalMile; break;
      case 'mile': meters = value * metersPerMile; break;
      case 'km': meters = value * metersPerKm; break;
      case 'hm': meters = value * metersPerHm; break;
      case 'dam': meters = value * metersPerDam; break;
      case 'fathom': meters = value * metersPerFathom; break;
      case 'meter': meters = value * metersPerMeter; break;
      case 'yard': meters = value * metersPerYard; break;
      case 'haat': meters = value * metersPerHaat; break;
      case 'feet': meters = value * metersPerFeet; break;
      case 'dm': meters = value * metersPerDm; break;
      case 'inch': meters = value * metersPerInch; break;
      case 'cm': meters = value * metersPerCm; break;
      case 'mm': meters = value * metersPerMm; break;
      case 'um': meters = value * metersPerUm; break;
      case 'nm': meters = value * metersPerNm; break;
      case 'angstrom': meters = value * metersPerAngstrom; break;
    }

    return {
      'pc': meters / metersPerParsec,
      'ly': meters / metersPerLightYear,
      'au': meters / metersPerAu,
      'nautical_mile': meters / metersPerNauticalMile,
      'mile': meters / metersPerMile,
      'km': meters / metersPerKm,
      'hm': meters / metersPerHm,
      'dam': meters / metersPerDam,
      'fathom': meters / metersPerFathom,
      'meter': meters / metersPerMeter,
      'yard': meters / metersPerYard,
      'haat': meters / metersPerHaat,
      'feet': meters / metersPerFeet,
      'dm': meters / metersPerDm,
      'inch': meters / metersPerInch,
      'cm': meters / metersPerCm,
      'mm': meters / metersPerMm,
      'um': meters / metersPerUm,
      'nm': meters / metersPerNm,
      'angstrom': meters / metersPerAngstrom,
    };
  }
}
