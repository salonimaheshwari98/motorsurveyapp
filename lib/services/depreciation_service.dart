import '../models/part.dart';

class DepreciationService {
  /// Calculates depreciation percentage based on material type and age in years.
  static double calculateDepreciation(String materialType, double ageYears) {
    materialType = materialType.toLowerCase();

    if (materialType.contains('metal')) {
      if (ageYears < 0.5) return 0.0;
      if (ageYears < 1) return 5.0;
      if (ageYears < 2) return 10.0;
      if (ageYears < 3) return 15.0;
      if (ageYears < 4) return 25.0;
      if (ageYears < 5) return 35.0;
      if (ageYears < 10) return 40.0;
      return 50.0;
    }

    if (materialType.contains('plastic') ||
        materialType.contains('rubber') ||
        materialType.contains('battery') ||
        materialType.contains('tyre')) {
      return 50.0;
    }

    if (materialType.contains('glass')) return 0.0;
    if (materialType.contains('labour') || materialType.contains('paint')) {
      return 0.0;
    }

    // default
    return 0.0;
  }

  static void applyDepreciation(PartItem item, double ageYears) {
    double percent = calculateDepreciation(item.materialType, ageYears);
    item.depreciationPercent = percent;
    item.approvedAmount = item.rate * (1 - percent / 100);
  }
}
