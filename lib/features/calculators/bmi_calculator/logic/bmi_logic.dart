class BmiLogic {
  static double calculate(double weightKg, double heightMeters) {
    if (heightMeters <= 0) return 0.0;
    return weightKg / (heightMeters * heightMeters);
  }

  static double ftInToMeters(int feet, int inches) {
    double totalInches = (feet * 12.0) + inches;
    return totalInches * 0.0254;
  }

  static String getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy Weight';
    if (bmi < 30) return 'Overweight';
    if (bmi < 35) return 'Class 1 Obesity';
    if (bmi < 40) return 'Class 2 Obesity';
    return 'Class 3 Obesity (Severe)';
  }
}
