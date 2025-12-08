import '../utils/api_wrapper.dart';
import '../models/schedule_model.dart';
import 'package:client/services/base_service.dart';

class ScheduleService extends BaseService<dynamic> {
  static final ScheduleService instance = ScheduleService._();
  factory ScheduleService() => instance;
  ScheduleService._();

  Future<ApiResponse<YearSchedule>> getYearSchedule(int year) async {
    try {
      final response = await dio.get('/schedule/year/$year');
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => YearSchedule.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(message: 'Gagal memuat jadwal', success: false);
    }
  }

  Future<ApiResponse<dynamic>> addHoliday({required String date, required String name}) async {
    try {
      final response = await dio.post('/schedule/holiday', data: {'date': date, 'name': name});
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      return ApiResponse(message: 'Gagal menambah libur', success: false);
    }
  }
}