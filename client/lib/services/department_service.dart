import 'dart:developer';
import 'package:client/models/department_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';
import 'package:dio/dio.dart';

class DepartmentService extends BaseService<DepartmentModel> {
  DepartmentService._();
  static final DepartmentService instance = DepartmentService._();

  /// Get all departments
  Future<ApiResponse<List<DepartmentModel>>> getDepartments() async {
    try {
      final response = await dio.get("/departments");

      log("Raw Response: ${response.data}");

      final responseData = response.data as Map<String, dynamic>;
      final List<DepartmentModel> departments = [];

      if (responseData['data'] != null) {
        final departmentsData = responseData['data'];

        // Handle both "departments" and "data" as list
        List<dynamic> rawList = [];
        if (departmentsData is List) {
          rawList = departmentsData;
        } else if (departmentsData is Map &&
            departmentsData['departments'] != null) {
          rawList = departmentsData['departments'] as List;
        }

        for (var item in rawList) {
          departments.add(DepartmentModel.fromJson(item as Map<String, dynamic>));
        }
      }

      return ApiResponse<List<DepartmentModel>>(
        message: responseData['message'] as String? ?? '',
        success: responseData['success'] as bool? ?? true,
        data: departments,
        error: responseData['error'],
      );
    } catch (e, s) {
      log("Error: Get Departments Failed", error: e, stackTrace: s);

      return ApiResponse<List<DepartmentModel>>(
        message: 'Gagal memuat data: ${e.toString()}',
        success: false,
        data: null,
        error: e,
      );
    }
  }

  /// Get department by ID
  Future<ApiResponse<DepartmentModel>> getDepartmentById(int id) async {
    try {
      final response = await dio.get("/departments/$id");

      final responseData = response.data as Map<String, dynamic>;

      DepartmentModel? department;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('department')) {
            department = DepartmentModel.fromJson(data['department']);
          } else {
            department = DepartmentModel.fromJson(data);
          }
        }
      }

      return ApiResponse<DepartmentModel>(
        message: responseData['message'] as String? ?? '',
        success: responseData['success'] as bool? ?? true,
        data: department,
        error: responseData['error'],
      );
    } catch (e, s) {
      log("Error: Get Department By ID Failed", error: e, stackTrace: s);

      return ApiResponse<DepartmentModel>(
        message: 'Gagal memuat data: ${e.toString()}',
        success: false,
        data: null,
        error: e,
      );
    }
  }

  /// Create new department (admin only)
  Future<ApiResponse<DepartmentModel>> createDepartment(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        "/departments",
        data: data,
        options: Options(headers: {"accept": "application/json"}),
      );

      final responseData = response.data as Map<String, dynamic>;

      DepartmentModel? department;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('department')) {
            department = DepartmentModel.fromJson(data['department']);
          } else {
            department = DepartmentModel.fromJson(data);
          }
        }
      }

      return ApiResponse<DepartmentModel>(
        message: responseData['message'] as String? ?? 'Berhasil membuat departemen',
        success: responseData['success'] as bool? ?? true,
        data: department,
        error: responseData['error'],
      );
    } on DioException catch (e, s) {
      log("Error: Create Department Failed", error: e, stackTrace: s);

      String errorMessage = 'Gagal membuat departemen';

      if (e.response?.statusCode == 422) {
        errorMessage = 'Validasi gagal: ${e.response?.data['message'] ?? ''}';
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      return ApiResponse<DepartmentModel>(
        message: errorMessage,
        success: false,
        data: null,
        error: e.response?.data,
      );
    }
  }

  /// Update department (admin only)
  Future<ApiResponse<DepartmentModel>> updateDepartment(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.patch(
        "/departments/$id",
        data: data,
        options: Options(headers: {"accept": "application/json"}),
      );

      final responseData = response.data as Map<String, dynamic>;

      DepartmentModel? department;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('department')) {
            department = DepartmentModel.fromJson(data['department']);
          } else {
            department = DepartmentModel.fromJson(data);
          }
        }
      }

      return ApiResponse<DepartmentModel>(
        message: responseData['message'] as String? ?? 'Berhasil memperbarui departemen',
        success: responseData['success'] as bool? ?? true,
        data: department,
        error: responseData['error'],
      );
    } on DioException catch (e, s) {
      log("Error: Update Department Failed", error: e, stackTrace: s);

      String errorMessage = 'Gagal memperbarui departemen';

      if (e.response?.statusCode == 422) {
        errorMessage = 'Validasi gagal: ${e.response?.data['message'] ?? ''}';
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      return ApiResponse<DepartmentModel>(
        message: errorMessage,
        success: false,
        data: null,
        error: e.response?.data,
      );
    }
  }

  /// Delete department (admin only)
  Future<ApiResponse<void>> deleteDepartment(int id) async {
    try {
      final response = await dio.delete(
        "/departments/$id",
        options: Options(headers: {"accept": "application/json"}),
      );

      final responseData = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        message: responseData['message'] as String? ?? 'Berhasil menghapus departemen',
        success: responseData['success'] as bool? ?? true,
        data: null,
        error: responseData['error'],
      );
    } on DioException catch (e, s) {
      log("Error: Delete Department Failed", error: e, stackTrace: s);

      String errorMessage = 'Gagal menghapus departemen';

      if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      return ApiResponse<void>(
        message: errorMessage,
        success: false,
        data: null,
        error: e.response?.data,
      );
    }
  }
}