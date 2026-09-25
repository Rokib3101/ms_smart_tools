class TimeLogic {
  static const double secondsPerMillennium = 31556952000.0; // 1000 * 365.2425 * 86400
  static const double secondsPerCentury = 3155695200.0;
  static const double secondsPerYuga = 378683424.0; // 12 * 365.2425 * 86400
  static const double secondsPerDecade = 315569520.0;
  static const double secondsPerYear = 31556952.0;
  static const double secondsPerMonth = 2629746.0;
  static const double secondsPerWeek = 604800.0;
  static const double secondsPerDay = 86400.0;
  static const double secondsPerHour = 3600.0;
  static const double secondsPerMinute = 60.0;

  static Map<String, double> convertTime(double value, String fromUnit) {
    double s = 0;
    switch (fromUnit) {
      case 'millennium': s = value * secondsPerMillennium; break;
      case 'century': s = value * secondsPerCentury; break;
      case 'yuga': s = value * secondsPerYuga; break;
      case 'decade': s = value * secondsPerDecade; break;
      case 'year': s = value * secondsPerYear; break;
      case 'month': s = value * secondsPerMonth; break;
      case 'week': s = value * secondsPerWeek; break;
      case 'day': s = value * secondsPerDay; break;
      case 'hour': s = value * secondsPerHour; break;
      case 'minute': s = value * secondsPerMinute; break;
      case 'second': s = value; break;
    }

    return {
      'millennium': s / secondsPerMillennium,
      'century': s / secondsPerCentury,
      'yuga': s / secondsPerYuga,
      'decade': s / secondsPerDecade,
      'year': s / secondsPerYear,
      'month': s / secondsPerMonth,
      'week': s / secondsPerWeek,
      'day': s / secondsPerDay,
      'hour': s / secondsPerHour,
      'minute': s / secondsPerMinute,
      'second': s,
    };
  }
}
