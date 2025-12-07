import 'dart:developer';
import 'dart:io';
import 'package:client/models/employee_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';
import 'package:dio/dio.dart';

class EmployeeService extends BaseService<EmployeeModel> {
  EmployeeService._();
  static final EmployeeService instance = EmployeeService._();

  /// Get all employees
  Future<ApiResponse<List<EmployeeModel>>> getEmployees() async {
    try {
      final response = await dio.get("/employees");

      log("Raw Response: ${response.data}");

      final responseData = response.data as Map<String, dynamic>;
      final List<EmployeeModel> employees = [];

      if (responseData['data'] != null &&
          responseData['data']['employees'] != null) {
        final employeesData = responseData['data']['employees'] as List;

        for (var item in employeesData) {
          employees.add(EmployeeModel.fromJson(item as Map<String, dynamic>));
        }
      }

      return ApiResponse<List<EmployeeModel>>(
        message: responseData['message'] as String? ?? '',
        success: responseData['success'] as bool? ?? true,
        data: employees,
        error: responseData['error'],
      );
    } catch (e, s) {
      log("Error: Get Employees Failed", error: e, stackTrace: s);

      return ApiResponse<List<EmployeeModel>>(
        message: 'Gagal memuat data: ${e.toString()}',
        success: false,
        data: null,
        error: e,
      );
    }
  }

  /// Get employee by ID
  Future<ApiResponse<EmployeeModel>> getEmployeeById(int id) async {
    try {
      final response = await dio.get("/employees/$id");

      final responseData = response.data as Map<String, dynamic>;

      EmployeeModel? employee;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('employee')) {
            employee = EmployeeModel.fromJson(data['employee']);
          } else {
            employee = EmployeeModel.fromJson(data);
          }
        }
      }

      return ApiResponse<EmployeeModel>(
        message: responseData['message'] as String? ?? '',
        success: responseData['success'] as bool? ?? true,
        data: employee,
        error: responseData['error'],
      );
    } catch (e, s) {
      log("Error: Get Employee By ID Failed", error: e, stackTrace: s);

      return ApiResponse<EmployeeModel>(
        message: 'Gagal memuat data: ${e.toString()}',
        success: false,
        data: null,
        error: e,
      );
    }
  }

  /// Update employee profile (by employee themselves)
  /// ✅ DENGAN SUPPORT UPLOAD FOTO
  Future<ApiResponse<EmployeeModel>> updateProfile(
    int id,
    Map<String, dynamic> data, {
    File? profilePhoto, // ✅ TAMBAHKAN PARAMETER INI
  }) async {
    try {
      // Gunakan FormData jika ada foto
      final formData = FormData.fromMap({'_method': 'PATCH', ...data});

      // Tambahkan foto jika ada
      if (profilePhoto != null) {
        formData.files.add(
          MapEntry(
            'profile_photo',
            await MultipartFile.fromFile(
              profilePhoto.path,
              filename: profilePhoto.path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.post(
        "/employee/profile/$id",
        data: formData,
        options: Options(
          headers: {
            "accept": "application/json",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;

      EmployeeModel? employee;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('employee')) {
            employee = EmployeeModel.fromJson(data['employee']);
          } else {
            employee = EmployeeModel.fromJson(data);
          }
        }
      }

      return ApiResponse<EmployeeModel>(
        message: responseData['message'] as String? ?? 'Berhasil diperbarui',
        success: responseData['success'] as bool? ?? true,
        data: employee,
        error: responseData['error'],
      );
    } on DioException catch (e, s) {
      log("Error: Update Profile Failed", error: e, stackTrace: s);

      String errorMessage = 'Gagal memperbarui profil';

      if (e.response?.statusCode == 422) {
        errorMessage = 'Validasi gagal: ${e.response?.data['message'] ?? ''}';
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      return ApiResponse<EmployeeModel>(
        message: errorMessage,
        success: false,
        data: null,
        error: e.response?.data,
      );
    }
  }

  /// Update employee management data (by admin)
  Future<ApiResponse<EmployeeModel>> updateManagement(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      data['_method'] = 'PATCH';

      final response = await dio.post(
        "/employee/management/$id",
        data: data,
        options: Options(headers: {"accept": "application/json"}),
      );

      final responseData = response.data as Map<String, dynamic>;

      EmployeeModel? employee;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('employee')) {
            employee = EmployeeModel.fromJson(data['employee']);
          } else {
            employee = EmployeeModel.fromJson(data);
          }
        }
      }

      return ApiResponse<EmployeeModel>(
        message: responseData['message'] as String? ?? 'Berhasil diperbarui',
        success: responseData['success'] as bool? ?? true,
        data: employee,
        error: responseData['error'],
      );
    } on DioException catch (e, s) {
      log("Error: Update Management Failed", error: e, stackTrace: s);

      String errorMessage = 'Gagal memperbarui data manajemen';

      if (e.response?.statusCode == 422) {
        errorMessage = 'Validasi gagal: ${e.response?.data['message'] ?? ''}';
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      return ApiResponse<EmployeeModel>(
        message: errorMessage,
        success: false,
        data: null,
        error: e.response?.data,
      );
    }
  }
}
