class LoginModel {
  final String token;
  final String userId;

  LoginModel({required this.token, required this.userId});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(token: json['token'], userId: json['userId']);
  }
}
