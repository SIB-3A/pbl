import 'package:client/services/base_service.dart';
import 'package:dio/dio.dart';
import 'package:client/services/location_service.dart';
import 'package:client/models/attendance_model.dart';
import 'package:client/utils/api_wrapper.dart';

class AttendanceService extends BaseService<dynamic> {
  static final AttendanceService instance = AttendanceService._internal();
  factory AttendanceService() => instance;
  AttendanceService._internal();

  // GET STATUS
  Future<ApiResponse<AttendanceStatus>> getStatus() async {
    try {
      final response = await dio.get('/absen/status');
      return ApiResponse.fromJson(
        response.data,
        (data) => AttendanceStatus.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // CLOCK IN
  Future<ApiResponse<Map<String, dynamic>>> clockIn() async {
    final position = await LocationService.getCurrent();

    if (position == null) {
      return ApiResponse(message: 'Izin lokasi ditolak!', success: false);
    }

    try {
      final response = await dio.post(
        '/absen/in',
        data: {'latitude': position.latitude, 'longitude': position.longitude},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // clockOut
  Future<ApiResponse<Map<String, dynamic>>> clockOut() async {
    final position = await LocationService.getCurrent();

    if (position == null) {
      return ApiResponse(message: 'Lokasi tidak tersedia', success: false);
    }

    try {
      final response = await dio.post(
        '/absen/out',
        data: {'latitude': position.latitude, 'longitude': position.longitude},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Lembur In
  Future<ApiResponse<Map<String, dynamic>>> lemburIn() async {
    final position = await LocationService.getCurrent();

    if (position == null) {
      return ApiResponse(message: 'Lokasi tidak tersedia', success: false);
    }

    try {
      final response = await dio.post(
        '/lembur/in',
        data: {'latitude': position.latitude, 'longitude': position.longitude},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  /// Lembur Out
  Future<ApiResponse<Map<String, dynamic>>> lemburOut() async {
    final position = await LocationService.getCurrent();

    if (position == null) {
      return ApiResponse(message: 'Lokasi tidak tersedia', success: false);
    }

    try {
      final response = await dio.post(
        '/lembur/out',
        data: {'latitude': position.latitude, 'longitude': position.longitude},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // handle error
  static ApiResponse<T> _handleError<T>(DioException e) {
    String message = 'Terjadi kesalahan';

    if (e.response?.data != null) {
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
      } else if (data is String) {
        message = 'Server error. Cek koneksi atau token!';
      }
    }

    // Kalau 401 → token salah / expired
    if (e.response?.statusCode == 401) {
      message = 'Sesi habis. Silakan login ulang.';
    }

    return ApiResponse(message: message, success: false);
  }
}
