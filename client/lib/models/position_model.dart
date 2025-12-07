class PositionModel {
  final int id;
  final String name;
  final double rateReguler;
  final double rateOvertime;

  PositionModel({
    required this.id,
    required this.name,
    required this.rateReguler,
    required this.rateOvertime,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['id'],
      name: json['name'],
      rateReguler: double.parse(json['rate_reguler'].toString()),
      rateOvertime: double.parse(json['rate_overtime'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rate_reguler': rateReguler,
        'rate_overtime': rateOvertime,
      };
}