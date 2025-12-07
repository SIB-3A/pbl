class UserModel<T> {
  final int id;
  final String email;
  final bool isAdmin;
  final String? createdAt;
  final String? updatedAt;
  final T? employee;

  UserModel({
    required this.id,
    required this.email,
    required this.isAdmin,
    this.createdAt,
    this.updatedAt,
    this.employee,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, [
    T Function(Object? jsonData)? dataParser,
  ]) {
    final T? parsedData;
    if (json['employee'] != null && dataParser != null) {
      parsedData = dataParser(json['employee']);
    } else if (json['employee'] != null && json['employee'] is T) {
      parsedData = json['employee'] as T;
    } else {
      parsedData = null;
    }

    return UserModel<T>(
      id: json["id"] is int ? json["id"] : int.tryParse(json["id"].toString()) ?? 0,
      email: json["email"] ?? '',
      isAdmin: json["is_admin"] ?? false,
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      employee: parsedData,
    );
  }

  // Convenience constructor without dataParser (for when employee is not needed)
  factory UserModel.fromJsonSimple(Map<String, dynamic> json) {
    return UserModel<T>(
      id: json["id"] is int ? json["id"] : int.tryParse(json["id"].toString()) ?? 0,
      email: json["email"] ?? '',
      isAdmin: json["is_admin"] ?? false,
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      employee: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'is_admin': isAdmin,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}