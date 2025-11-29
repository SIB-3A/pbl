import 'package:client/models/user_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';

class UserService extends BaseService<UserModel> {
  UserService._();
  static final UserService instance = UserService._();

  Future<ApiResponse<List<UserModel>>> getPosts() async {
    final response = await dio.get("/api/users");

    return ApiResponse<List<UserModel>>.fromJson(response.data, (jsonData) {
      return parseData(jsonData, "users", UserModel.fromJson);
    });
  }
}
