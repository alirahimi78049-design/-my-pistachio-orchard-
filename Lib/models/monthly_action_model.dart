class MonthlyActionModel {
  final String? id;
  final String landId;
  final int solarYear;
  final String month;
  final String? mainActionNote;
  final String? treeObservationNote;
  final List<String> irrigationDates;

  MonthlyActionModel({
    this.id,
    required this.landId,
    required this.solarYear,
    required this.month,
    this.mainActionNote,
    this.treeObservationNote,
    this.irrigationDates = const [],
  });

  factory MonthlyActionModel.fromJson(Map<String, dynamic> json) {
    return MonthlyActionModel(
      id: json['id'] as String?,
      landId: json['land_id'] as String,
      solarYear: json['solar_year'] as int,
      month: json['month'] as String,
      mainActionNote: json['main_action_note'] as String?,
      treeObservationNote: json['tree_observation_note'] as String?,
      irrigationDates: (json['irrigation_dates'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'land_id': landId,
      'solar_year': solarYear,
      'month': month,
      'main_action_note': mainActionNote,
      'tree_observation_note': treeObservationNote,
      'irrigation_dates': irrigationDates,
    };
  }
}

