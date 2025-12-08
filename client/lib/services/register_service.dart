import 'dart:developer';

import 'package:client/models/register_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';
import 'package:dio/dio.dart';

class RegisterService extends BaseService {
  RegisterService._();

  static RegisterService instance = RegisterService._();

  Future<ApiResponse> createUser(RegisterModel input) async {
    final response = await dio.post(
      "/register",
      data: {
        "email": input.email,
        "password": input.password,
        "first_name": input.firstName,
        "last_name": input.lastName,
        "gender": input.gender,
        "address": input.address,
        "position_id": input.positionId,
        "department_id": input.departmentId,
      },
      options: Options(
        headers: Map.from({"accept": "application/json"}),
        validateStatus: (_) => true,
      ),
    );
    final json = response.data;
    if (response.statusCode != 200 && response.statusCode != 201) {
      log("Error: Register failed: ${json['message']}");
      return ApiResponse(
        message: "Gagal membuat akun",
        success: false,
        data: json["data"],
        error: json["error"],
      );
    }
    return ApiResponse(
      message: json["message"],
      success: true,
      data: json["data"],
      error: json["error"],
    );
  }
}
