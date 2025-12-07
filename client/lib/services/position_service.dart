import 'dart:developer';
import 'package:client/models/payroll_model.dart';
import 'package:client/models/position_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PositionService extends BaseService<PositionModel> {
  PositionService._();
  static final PositionService instance = PositionService._();
  final storage = const FlutterSecureStorage();

  /// Get all positions
  Future<ApiResponse<List<PositionModel>>> getPositions() async {
    try {
      final response = await dio.get("/positions");

      log("Raw Response: ${response.data}");

      final responseData = response.data as Map<String, dynamic>;
      final List<PositionModel> positions = [];

      if (responseData['data'] != null) {
        final positionsData = responseData['data'];

        // Handle both "positions" and "data" as list
        List<dynamic> rawList = [];
        if (positionsData is List) {
          rawList = positionsData;
        } else if (positionsData is Map && positionsData['positions'] != null) {
          rawList = positionsData['positions'] as List;
        }

        for (var item in rawList) {
          positions.add(PositionModel.fromJson(item as Map<String, dynamic>));
        }
      }

      return ApiResponse<List<PositionModel>>(
        message: responseData['message'] as String? ?? '',
        success: responseData['success'] as bool? ?? true,
        data: positions,
        error: responseData['error'],
      );
    } catch (e, s) {
      log("Error: Get Positions Failed", error: e, stackTrace: s);

      return ApiResponse<List<PositionModel>>(
        message: 'Gagal memuat data: ${e.toString()}',
        success: false,
        data: null,
        error: e,
      );
    }
  }

  /// Get position by ID
  Future<ApiResponse<PositionModel>> getPositionById(int id) async {
    try {
      final response = await dio.get("/positions/$id");

      final responseData = response.data as Map<String, dynamic>;

      PositionModel? position;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('position')) {
            position = PositionModel.fromJson(data['position']);
          } else {
            position = PositionModel.fromJson(data);
          }
        }
      }

      return ApiResponse<PositionModel>(
        message: responseData['message'] as String? ?? '',
        success: responseData['success'] as bool? ?? true,
        data: position,
        error: responseData['error'],
      );
    } catch (e, s) {
      log("Error: Get Position By ID Failed", error: e, stackTrace: s);

      return ApiResponse<PositionModel>(
        message: 'Gagal memuat data: ${e.toString()}',
        success: false,
        data: null,
        error: e,
      );
    }
  }

  /// Get user payroll data (untuk employee)
  Future<ApiResponse<PayrollModel>> getUserPayroll() async {
    try {
      final userId = await storage.read(key: "userId");

      if (userId == null) {
        return ApiResponse<PayrollModel>(
          message: 'User ID tidak ditemukan',
          success: false,
          data: null,
          error: 'No user ID',
        );
      }

      final response = await dio.get("/position/$userId");

      final responseData = response.data as Map<String, dynamic>;

      PayrollModel? payroll;

      if (responseData['data'] != null) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (data.containsKey('position')) {
          payroll = PayrollModel.fromJson(data['position']);
        }
      }

      return ApiResponse<PayrollModel>(
        message: responseData['message'] as String? ?? '',
        success: responseData['success'] as bool? ?? true,
        data: payroll,
        error: responseData['error'],
      );
    } catch (e, s) {
      log("Error: Get User Payroll Failed", error: e, stackTrace: s);

      return ApiResponse<PayrollModel>(
        message: 'Gagal memuat data payroll: ${e.toString()}',
        success: false,
        data: null,
        error: e,
      );
    }
  }

  /// Create new position (admin only)
  Future<ApiResponse<PositionModel>> createPosition(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.post(
        "/positions",
        data: data,
        options: Options(headers: {"accept": "application/json"}),
      );

      final responseData = response.data as Map<String, dynamic>;

      PositionModel? position;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('position')) {
            position = PositionModel.fromJson(data['position']);
          } else {
            position = PositionModel.fromJson(data);
          }
        }
      }

      return ApiResponse<PositionModel>(
        message:
            responseData['message'] as String? ?? 'Berhasil membuat posisi',
        success: responseData['success'] as bool? ?? true,
        data: position,
        error: responseData['error'],
      );
    } on DioException catch (e, s) {
      log("Error: Create Position Failed", error: e, stackTrace: s);

      String errorMessage = 'Gagal membuat posisi';

      if (e.response?.statusCode == 422) {
        errorMessage = 'Validasi gagal: ${e.response?.data['message'] ?? ''}';
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      return ApiResponse<PositionModel>(
        message: errorMessage,
        success: false,
        data: null,
        error: e.response?.data,
      );
    }
  }

  /// Update position (admin only)
  Future<ApiResponse<PositionModel>> updatePosition(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.patch(
        "/positions/$id",
        data: data,
        options: Options(headers: {"accept": "application/json"}),
      );

      final responseData = response.data as Map<String, dynamic>;

      PositionModel? position;

      if (responseData['data'] != null) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('position')) {
            position = PositionModel.fromJson(data['position']);
          } else {
            position = PositionModel.fromJson(data);
          }
        }
      }

      return ApiResponse<PositionModel>(
        message:
            responseData['message'] as String? ?? 'Berhasil memperbarui posisi',
        success: responseData['success'] as bool? ?? true,
        data: position,
        error: responseData['error'],
      );
    } on DioException catch (e, s) {
      log("Error: Update Position Failed", error: e, stackTrace: s);

      String errorMessage = 'Gagal memperbarui posisi';

      if (e.response?.statusCode == 422) {
        errorMessage = 'Validasi gagal: ${e.response?.data['message'] ?? ''}';
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }

      return ApiResponse<PositionModel>(
        message: errorMessage,
        success: false,
        data: null,
        error: e.response?.data,
      );
    }
  }

  /// Delete position (admin only)
  Future<ApiResponse<void>> deletePosition(int id) async {
    try {
      final response = await dio.delete(
        "/positions/$id",
        options: Options(headers: {"accept": "application/json"}),
      );

      final responseData = response.data as Map<String, dynamic>;

      return ApiResponse<void>(
        message:
            responseData['message'] as String? ?? 'Berhasil menghapus posisi',
        success: responseData['success'] as bool? ?? true,
        data: null,
        error: responseData['error'],
      );
    } on DioException catch (e, s) {
      log("Error: Delete Position Failed", error: e, stackTrace: s);
      log("Response status: ${e.response?.statusCode}");
      log("Response data: ${e.response?.data}");

      String errorMessage = 'Gagal menghapus posisi';

      if (e.response?.statusCode == 422) {
        // Handle validation errors
        final responseData = e.response?.data;
        if (responseData != null && responseData is Map) {
          final errors = responseData['errors'];
          if (errors != null && errors is Map) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else if (firstError is String) {
              errorMessage = firstError;
            }
          } else if (responseData['message'] != null) {
            errorMessage = responseData['message'];
          }
        }
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Posisi tidak ditemukan';
      } else if (e.response?.statusCode == 500) {
        final responseData = e.response?.data;
        if (responseData != null &&
            responseData is Map &&
            responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else {
          errorMessage = 'Terjadi kesalahan pada server. Silakan coba lagi.';
        }
      } else if (e.response?.data != null &&
          e.response?.data['message'] != null) {
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
