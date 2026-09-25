enum ScannerFilterType {
  original('Original', 'Original'),
  auto('Auto', 'Auto'),
  enhanced('Enhanced', 'Enhanced'),
  grayscale('Grayscale', 'Grayscale'),
  bw('B&W', 'B&W'),
  shadow('Shadow Reduction', 'Shadow Reduction');

  final String labelEn;
  final String labelBn;
  const ScannerFilterType(this.labelEn, this.labelBn);
}
