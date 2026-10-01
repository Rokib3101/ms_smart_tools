class PhysicsLogic {
  // Speed: Ref km/h
  static Map<String, double> convertSpeed(double value, String fromUnit) {
    double kmh = 0;
    switch (fromUnit) {
      case 'c': kmh = value * 1079252848.8; break;
      case 'kms': kmh = value * 3600.0; break;
      case 'ms': kmh = value * 3.6; break;
      case 'kn': kmh = value * 1.852; break;
      case 'mph': kmh = value * 1.60934; break;
      case 'kmh': kmh = value; break;
    }
    return {
      'c': kmh / 1079252848.8,
      'kms': kmh / 3600.0,
      'ms': kmh / 3.6,
      'kn': kmh / 1.852,
      'mph': kmh / 1.60934,
      'kmh': kmh,
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
      case 'atm': pa = value * 101325.0; break;
      case 'bar': pa = value * 100000.0; break;
      case 'psi': pa = value * 6894.76; break;
      case 'inhg': pa = value * 3386.389; break;
      case 'mmhg': pa = value * 133.3224; break;
      case 'mbar': pa = value * 100.0; break;
      case 'pa': pa = value; break;
    }
    return {
      'atm': pa / 101325.0,
      'bar': pa / 100000.0,
      'psi': pa / 6894.76,
      'inhg': pa / 3386.389,
      'mmhg': pa / 133.3224,
      'mbar': pa / 100.0,
      'pa': pa,
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

  // Power & Energy combined: Ref Watt (W)
  static Map<String, double> convertPowerEnergy(double value, String fromUnit) {
    double watts = 0;
    switch (fromUnit) {
      case 'w': watts = value; break;
      case 'kw': watts = value * 1000.0; break;
      case 'hp': watts = value * 745.7; break;
      case 'j': watts = value; break;
      case 'cal': watts = value * jPerCalorie; break;
      case 'kcal': watts = value * jPerKcal; break;
      case 'btu': watts = value * jPerBtu; break;
      case 'kwh': watts = value * (jPerKwh / 3600.0); break;
      case 'ev': watts = value * jPerEv; break;
    }

    double j = watts;
    return {
      'w': watts,
      'kw': watts / 1000.0,
      'hp': watts / 745.7,
      'j': j,
      'cal': j / jPerCalorie,
      'kcal': j / jPerKcal,
      'btu': j / jPerBtu,
      'kwh': (watts * 3600.0) / jPerKwh,
      'ev': j / jPerEv,
    };
  }

  // Energy: Ref Joule (J)
  static const double jPerMwh = 3600000000.0;
  static const double jPerCalorie = 4.184;
  static const double jPerKcal = 4184.0;
  static const double jPerBtu = 1055.06;
  static const double jPerKj = 1000.0;
  static const double jPerEv = 1.60218e-19;
  static const double jPerKwh = 3600000.0;

  static Map<String, double> convertEnergy(double value, String fromUnit) {
    double j = 0;
    switch (fromUnit) {
      case 'mwh': j = value * jPerMwh; break;
      case 'kwh': j = value * jPerKwh; break;
      case 'kcal': j = value * jPerKcal; break;
      case 'btu': j = value * jPerBtu; break;
      case 'kj': j = value * jPerKj; break;
      case 'cal': j = value * jPerCalorie; break;
      case 'j': j = value; break;
      case 'ev': j = value * jPerEv; break;
    }
    return {
      'mwh': j / jPerMwh,
      'kwh': j / jPerKwh,
      'kcal': j / jPerKcal,
      'btu': j / jPerBtu,
      'kj': j / jPerKj,
      'cal': j / jPerCalorie,
      'j': j,
      'ev': j / jPerEv,
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
