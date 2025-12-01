class UserModel {
  final int id;
  final String email;
  final bool isAdmin;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.isAdmin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      email: json["email"],
      isAdmin: json["is_admin"],
      createdAt: json["created_at"] != null ? null : json["created_at"],
      updatedAt: json["updated_at"] != null ? null : json["updated_at"],
    );
  }
}
