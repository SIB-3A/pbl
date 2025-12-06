class PayrollModel {
  final int id;
  final String name;
  final int rateReguler;
  final int rateOvertime;

  PayrollModel({
    required this.id,
    required this.name,
    required this.rateReguler,
    required this.rateOvertime,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      id: json["id"],
      name: json["name"],
      rateReguler: json["rate_reguler"],
      rateOvertime: json["rate_overtime"],
    );
  }
}
