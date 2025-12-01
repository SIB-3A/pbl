class AuthModel {
  final String token;
  final int userId;

  AuthModel({required this.token, required this.userId});

  factory AuthModel.fromJson(dynamic json) {
    return AuthModel(token: json["token"], userId: json["user_id"]);
  }
}
