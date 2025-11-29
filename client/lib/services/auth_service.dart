import 'dart:developer';

import 'package:client/models/auth_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';
import 'package:dio/dio.dart';

class AuthService extends BaseService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final login = await dio.post(
        "/login",
        data: {"email": email, "password": password, "device_name": "android"},
        options: Options(headers: Map.from({"accept": "application/json"})),
      );
      final response = ApiResponse.fromJson(
        login.data,
        (e) => AuthModel.fromJson(e),
      );

      return {"success": true};
    } catch (e, s) {
      log("Error: Login Failed", error: e, stackTrace: s);
      return {"success": false, "error": e.toString()};
    }
  }
}
