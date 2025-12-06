import 'package:client/models/payroll_model.dart';
import 'package:client/models/position_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PositionService extends BaseService {
  PositionService._();

  static PositionService instance = PositionService._();
  final storage = FlutterSecureStorage();

  Future<ApiResponse<List<PositionModel>>> getPositions() async {
    final response = await dio.get("/positions");
    final json = response.data;

    final rawPositions = json["data"] as List;
    final positions = rawPositions.map((item) {
      return PositionModel.fromJson(item);
    }).toList();

    return ApiResponse<List<PositionModel>>(
      message: json["message"],
      success: json["success"],
      data: positions,
      error: json["error"],
    );
  }

  Future<ApiResponse<PayrollModel>> getUserPayroll() async {
    final userId = await storage.read(key: "userId");
    final response = await dio.get("/position/$userId");
    final json = response.data;

    final data = ApiResponse<PayrollModel>.fromJson(json, (jsonData) {
      final rawPosition = jsonData as Map<String, dynamic>;
      return PayrollModel.fromJson(rawPosition["position"]);
    });

    print(data);

    return data;
  }
}
