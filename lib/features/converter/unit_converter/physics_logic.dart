class PhysicsLogic {
  // Speed: Ref km/h
  static Map<String, double> convertSpeed(double value, String fromUnit) {
    double kmh = 0;
    switch (fromUnit) {
      case 'kmh': kmh = value; break;
      case 'ms': kmh = value * 3.6; break;
      case 'mph': kmh = value * 1.60934; break;
    }
    return {
      'kmh': kmh,
      'ms': kmh / 3.6,
      'mph': kmh / 1.60934,
    };
  }

  // Temperature
  static Map<String, double> convertTemp(double value, String fromUnit) {
    double celsius = 0;
    switch (fromUnit) {
      case 'c': celsius = value; break;
      case 'f': celsius = (value - 32) * 5 / 9; break;
      case 'k': celsius = value - 273.15; break;
    }
    return {
      'c': celsius,
      'f': (celsius * 9 / 5) + 32,
      'k': celsius + 273.15,
    };
  }

  // Pressure: Ref Pascal
  static Map<String, double> convertPressure(double value, String fromUnit) {
    double pa = 0;
    switch (fromUnit) {
      case 'pa': pa = value; break;
      case 'bar': pa = value * 100000.0; break;
      case 'psi': pa = value * 6894.76; break;
    }
    return {
      'pa': pa,
      'bar': pa / 100000.0,
      'psi': pa / 6894.76,
    };
  }

  // Power: Ref Watt
  static Map<String, double> convertPower(double value, String fromUnit) {
    double w = 0;
    switch (fromUnit) {
      case 'w': w = value; break;
      case 'kw': w = value * 1000.0; break;
      case 'hp': w = value * 745.7; break;
    }
    return {
      'w': w,
      'kw': w / 1000.0,
      'hp': w / 745.7,
    };
  }

  // Energy: Ref Joule (J)
  static const double jPerCalorie = 4.184;
  static const double jPerKcal = 4184.0;
  static const double jPerBtu = 1055.06;
  static const double jPerEv = 1.60218e-19;
  static const double jPerKwh = 3600000.0;

  static Map<String, double> convertEnergy(double value, String fromUnit) {
    double j = 0;
    switch (fromUnit) {
      case 'j': j = value; break;
      case 'cal': j = value * jPerCalorie; break;
      case 'kcal': j = value * jPerKcal; break;
      case 'btu': j = value * jPerBtu; break;
      case 'ev': j = value * jPerEv; break;
      case 'kwh': j = value * jPerKwh; break;
    }
    return {
      'j': j,
      'cal': j / jPerCalorie,
      'kcal': j / jPerKcal,
      'btu': j / jPerBtu,
      'ev': j / jPerEv,
      'kwh': j / jPerKwh,
    };
  }

  // Data: Ref Byte (B)
  static const double bPerBit = 0.125;
  static const double bPerKb = 1024.0;
  static const double bPerMb = 1048576.0;
  static const double bPerGb = 1073741824.0;
  static const double bPerTb = 1099511627776.0;

  static Map<String, double> convertData(double value, String fromUnit) {
    double bytes = 0;
    switch (fromUnit) {
      case 'bit': bytes = value * bPerBit; break;
      case 'b': bytes = value; break;
      case 'kb': bytes = value * bPerKb; break;
      case 'mb': bytes = value * bPerMb; break;
      case 'gb': bytes = value * bPerGb; break;
      case 'tb': bytes = value * bPerTb; break;
    }
    return {
      'bit': bytes / bPerBit,
      'b': bytes,
      'kb': bytes / bPerKb,
      'mb': bytes / bPerMb,
      'gb': bytes / bPerGb,
      'tb': bytes / bPerTb,
    };
  }
}
