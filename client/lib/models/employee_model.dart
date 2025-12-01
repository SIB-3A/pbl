class EmployeeModel {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String gender;
  final String address;
  final String createdAt;
  final String updatedAt;
  final int positionId;
  final int departementId;
  final String employementStatus;

  EmployeeModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.positionId,
    required this.departementId,
    required this.employementStatus,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json["id"].toString(),
      userId: json["user_id"].toString(),
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      gender: json["gender"] ?? "",
      address: json["address"] ?? "",
      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      positionId: json["position_id"] is int
          ? json["position_id"]
          : int.tryParse(json["position_id"].toString()) ?? 0,
      departementId: json["departement_id"] is int
          ? json["departement_id"]
          : int.tryParse(json["departement_id"].toString()) ?? 0,
      employementStatus:
          json["employment_status"] ?? json["employement_status"] ?? "",
    );
  }
}
