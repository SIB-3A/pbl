class UserModel<T> {
  final int id;
  final String email;
  final bool isAdmin;
  final String createdAt;
  final String updatedAt;
  final T? employee;

  UserModel({
    required this.id,
    required this.email,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.employee,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? jsonData)? dataParser,
  ) {
    final employeeData = json['employee'];

    final T? parsedData;
    if (dataParser != null) {
      parsedData = dataParser(employeeData);
    } else if (employeeData is T) {
      parsedData = employeeData;
    } else {
      parsedData = null; // or throw if you want strict behavior
    }

    return UserModel<T>(
      id: json["id"],
      email: json["email"],
      isAdmin: json["is_admin"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      employee: parsedData,
    );
  }
}
