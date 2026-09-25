class WeightVolumeLogic {
  // Weight factors relative to Gram (g)
  static const double gPerTon = 1000000.0;
  static const double gPerQuintal = 100000.0;
  static const double gPerMon = 40000.0;
  static const double gPerStone = 6350.29;
  static const double gPerPound = 453.592;
  static const double gPerOunce = 28.3495;

  // Volume factors relative to Milliliter (ml)
  static const double mlPerMegaliter = 1000000000.0;
  static const double mlPerLiter = 1000.0;
  static const double mlPerGallon = 3785.41;
  static const double mlPerQuart = 946.353;
  static const double mlPerPint = 473.176;
  static const double mlPerFloz = 29.5735;
  static const double mlPerTsp = 4.92892;
  static const double mlPerTbsp = 14.7868;
  static const double mlPerCup = 240.0;
  static const double mlPerUl = 0.001;

  // New liquid factors relative to Liter
  static const double literPerKl = 1000.0;
  static const double literPerHl = 100.0;
  static const double literPerDal = 10.0;
  static const double literPerDl = 0.1;
  static const double literPerCl = 0.01;

  static Map<String, double> convertWeight(double value, String fromUnit) {
    double g = 0;
    switch (fromUnit) {
      case 'ton': g = value * gPerTon; break;
      case 'quintal': g = value * gPerQuintal; break;
      case 'mon': g = value * gPerMon; break;
      case 'stone': g = value * gPerStone; break;
      case 'kg': g = value * 1000.0; break;
      case 'lb': g = value * gPerPound; break;
      case 'hg': g = value * 100.0; break;
      case 'dag': g = value * 10.0; break;
      case 'oz': g = value * gPerOunce; break;
      case 'g': g = value; break;
      case 'dg': g = value * 0.1; break;
      case 'cg': g = value * 0.01; break;
      case 'mg': g = value * 0.001; break;
      case 'ug': g = value * 0.000001; break;
      case 'ng': g = value * 0.000000001; break;
    }
    return {
      'ton': g / gPerTon,
      'quintal': g / gPerQuintal,
      'mon': g / gPerMon,
      'stone': g / gPerStone,
      'kg': g / 1000.0,
      'lb': g / gPerPound,
      'hg': g / 100.0,
      'oz': g / gPerOunce,
      'dag': g / 10.0,
      'g': g,
      'dg': g / 0.1,
      'cg': g / 0.01,
      'mg': g / 0.001,
      'ug': g / 0.000001,
      'ng': g / 0.000000001,
    };
  }

  static Map<String, double> convertVolume(double value, String fromUnit) {
    double ml = 0;
    switch (fromUnit) {
      case 'kl': ml = value * literPerKl * mlPerLiter; break;
      case 'hl': ml = value * literPerHl * mlPerLiter; break;
      case 'dal': ml = value * literPerDal * mlPerLiter; break;
      case 'gallon': ml = value * mlPerGallon; break;
      case 'liter': ml = value * mlPerLiter; break;
      case 'cup': ml = value * mlPerCup; break;
      case 'dl': ml = value * literPerDl * mlPerLiter; break;
      case 'tbsp': ml = value * mlPerTbsp; break;
      case 'cl': ml = value * literPerCl * mlPerLiter; break;
      case 'tsp': ml = value * mlPerTsp; break;
      case 'ml': ml = value; break;
    }
    return {
      'kl': ml / (literPerKl * mlPerLiter),
      'hl': ml / (literPerHl * mlPerLiter),
      'dal': ml / (literPerDal * mlPerLiter),
      'gallon': ml / mlPerGallon,
      'liter': ml / mlPerLiter,
      'cup': ml / mlPerCup,
      'dl': ml / (literPerDl * mlPerLiter),
      'tbsp': ml / mlPerTbsp,
      'cl': ml / (literPerCl * mlPerLiter),
      'tsp': ml / mlPerTsp,
      'ml': ml,
    };
  }
}
