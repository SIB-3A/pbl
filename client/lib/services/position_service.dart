import 'dart:convert'; 
import 'dart:developer';
import 'package:client/models/position_model.dart';
import 'package:client/services/base_service.dart';
import 'package:client/utils/api_wrapper.dart';
import 'package:dio/dio.dart';

class PositionService extends BaseService<PositionModel> {
  PositionService._();
  static final PositionService instance = PositionService._();

  /// Get all positions
  Future<ApiResponse<List<PositionModel>>> getPositions() async {
    try {
      final response = await dio.get("/positions");

      return ApiResponse<List<PositionModel>>.fromJson(response.data, (
        jsonData,
      ) {
        return parseData(jsonData, "positions", PositionModel.fromJson);
      });
    } catch (e, s) {
      log("Error: Get Positions Failed", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Get position by ID
  Future<ApiResponse<PositionModel>> getPositionById(int id) async {
    try {
      final response = await dio.get("/positions/$id");

      return ApiResponse<PositionModel>.fromJson(response.data, (jsonData) {
        final data = jsonData as Map<String, dynamic>;
        return PositionModel.fromJson(data['position']);
      });
    } catch (e, s) {
      log("Error: Get Position By ID Failed", error: e, stackTrace: s);
      rethrow;
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

      return ApiResponse<PositionModel>.fromJson(response.data, (jsonData) {
        final responseData = jsonData as Map<String, dynamic>;
        return PositionModel.fromJson(responseData['position']);
      });
    } on DioException catch (e, s) {
      log("Error: Create Position Failed", error: e, stackTrace: s);

      if (e.response?.statusCode == 422) {
        throw Exception('Validasi gagal: ${e.response?.data['errors']}');
      }

      throw Exception(e.response?.data['message'] ?? 'Gagal membuat posisi');
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

      return ApiResponse<PositionModel>.fromJson(response.data, (jsonData) {
        final responseData = jsonData as Map<String, dynamic>;
        return PositionModel.fromJson(responseData['position']);
      });
    } on DioException catch (e, s) {
      log("Error: Update Position Failed", error: e, stackTrace: s);

      if (e.response?.statusCode == 422) {
        throw Exception('Validasi gagal: ${e.response?.data['errors']}');
      }

      throw Exception(
        e.response?.data['message'] ?? 'Gagal memperbarui posisi',
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

      return ApiResponse<void>.fromJson(response.data, (jsonData) => null);
      
    } on DioException catch (e, s) {
      log("Error: Delete Position Failed", error: e, stackTrace: s);
      
      // Debug log untuk melihat response detail
      log("Response status: ${e.response?.statusCode}");
      log("Response data: ${e.response?.data}");
      
      if (e.response?.statusCode == 422) {
        // Handle validation errors
        final responseData = e.response?.data;
        if (responseData != null && responseData is Map) {
          final errors = responseData['errors'];
          if (errors != null && errors is Map) {
            // Ambil pesan error pertama
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              throw Exception(firstError.first);
            } else if (firstError is String) {
              throw Exception(firstError);
            }
          }
          final message = responseData['message'];
          if (message != null) {
            throw Exception(message);
          }
        }
        throw Exception('Validasi gagal');
      }
      
      if (e.response?.statusCode == 404) {
        throw Exception('Posisi tidak ditemukan');
      }
      
      if (e.response?.statusCode == 500) {
        final responseData = e.response?.data;
        if (responseData != null && responseData is Map) {
          final message = responseData['message'];
          if (message != null) {
            throw Exception(message);
          }
        }
        throw Exception('Terjadi kesalahan pada server. Silakan coba lagi.');
      }
      
      throw Exception(e.message ?? 'Gagal menghapus posisi');
    } catch (e, s) {
      log("Error: Delete Position Failed (non-Dio)", error: e, stackTrace: s);
      rethrow;
    }
  }
}