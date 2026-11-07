class LabTestModel {
  final String? id;
  final String landId;
  final int solarYear;
  final String? leafTestDate;
  final Map<String, dynamic> leafElements;
  final String soilType;
  final String? soilTestDate;
  final Map<String, dynamic> soilElements;
  final String? waterTestDate;
  final Map<String, dynamic> waterElements;

  LabTestModel({
    this.id,
    required this.landId,
    required this.solarYear,
    this.leafTestDate,
    this.leafElements = const {},
    this.soilType = 'رسی',
    this.soilTestDate,
    this.soilElements = const {},
    this.waterTestDate,
    this.waterElements = const {},
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    return LabTestModel(
      id: json['id'] as String?,
      landId: json['land_id'] as String,
      solarYear: json['solar_year'] as int,
      leafTestDate: json['leaf_test_date'] as String?,
      leafElements: (json['leaf_elements'] as Map<String, dynamic>?) ?? {},
      soilType: json['soil_type'] as String? ?? 'رسی',
      soilTestDate: json['soil_test_date'] as String?,
      soilElements: (json['soil_elements'] as Map<String, dynamic>?) ?? {},
      waterTestDate: json['water_test_date'] as String?,
      waterElements: (json['water_elements'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'land_id': landId,
      'solar_year': solarYear,
      'leaf_test_date': leafTestDate,
      'leaf_elements': leafElements,
      'soil_type': soilType,
      'soil_test_date': soilTestDate,
      'soil_elements': soilElements,
      'water_test_date': waterTestDate,
      'water_elements': waterElements,
    };
  }
}

