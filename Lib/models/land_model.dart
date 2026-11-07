class LandModel {
  final String? id;
  final String userPhone;
  final String name;
  final double areaValue;
  final String unit;
  final double? standardAreaSqm;
  final List<String> treeVarieties;
  final int irrigationIntervalDays;

  LandModel({
    this.id,
    required this.userPhone,
    required this.name,
    required this.areaValue,
    this.unit = 'هکتار',
    this.standardAreaSqm,
    this.treeVarieties = const [],
    this.irrigationIntervalDays = 13,
  });

  factory LandModel.fromJson(Map<String, dynamic> json) {
    return LandModel(
      id: json['id'] as String?,
      userPhone: json['user_phone'] as String,
      name: json['name'] as String,
      areaValue: (json['area_value'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'هکتار',
      standardAreaSqm: json['standard_area_sqm'] != null
          ? (json['standard_area_sqm'] as num).toDouble()
          : null,
      treeVarieties: (json['tree_varieties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      irrigationIntervalDays: json['irrigation_interval_days'] as int? ?? 13,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_phone': userPhone,
      'name': name,
      'area_value': areaValue,
      'unit': unit,
      if (standardAreaSqm != null) 'standard_area_sqm': standardAreaSqm,
      'tree_varieties': treeVarieties,
      'irrigation_interval_days': irrigationIntervalDays,
    };
  }
}

