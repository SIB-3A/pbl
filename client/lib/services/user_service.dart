import 'package:client/models/employee_model.dart';
import 'package:client/models/user_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService extends BaseService<UserModel> {
  UserService._();
  static final UserService instance = UserService._();

  Future<ApiResponse<List<UserModel<EmployeeModel>>>> getUsers() async {
    final response = await dio.get("/users");

    final json = response.data;
    final rawList = json["data"] as List;

    final users = rawList.map((item) {
      return UserModel<EmployeeModel>.fromJson(
        item,
        (employeeJson) =>
            EmployeeModel.fromJson(employeeJson as Map<String, dynamic>),
      );
    }).toList();

    return ApiResponse<List<UserModel<EmployeeModel>>>(
      message: json["message"] ?? "",
      success: json["success"] ?? false,
      data: users,
      error: json["error"],
    );
  }

  Future<ApiResponse<UserModel<EmployeeModel>>> getUser(int? userId) async {
    final storage = FlutterSecureStorage();
    int? user;
    if (userId == null) {
      final userIdString = await storage.read(key: "userId");
      user = int.tryParse(userIdString ?? "");
    } else {
      user = userId;
    }
    final response = await dio.get("/user/$user");
    return ApiResponse.fromJson(response.data, (json) {
      return UserModel.fromJson(json as Map<String, dynamic>, (employee) {
        return EmployeeModel.fromJson(employee as Map<String, dynamic>);
      });
    });
  }
}
