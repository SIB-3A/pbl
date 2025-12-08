class ScheduleItem {
  final String date;
  final String dayOfWeek;
  final bool isWorkday;
  final String? holidayName;
  final String? holidayType;

  ScheduleItem({
    required this.date,
    required this.dayOfWeek,
    required this.isWorkday,
    this.holidayName,
    this.holidayType,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      date: json['date'] as String,
      dayOfWeek: json['day_of_week'] as String? ?? '',
      isWorkday: _parseBool(json['is_workday']),
      holidayName: json['holiday_name'] as String?,
      holidayType: json['holiday_type'] as String?,
    );
  }

  // helper untuk meng-handle true/false atau "true"/"false" atau 1/0
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final lower = v.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      return false;
    }
    return false;
  }
}

class YearSchedule {
  final int year;
  final int totalDays;
  final int totalWorkdays;
  final List<ScheduleItem> schedules;

  YearSchedule({
    required this.year,
    required this.totalDays,
    required this.totalWorkdays,
    required this.schedules,
  });

  factory YearSchedule.fromJson(Map<String, dynamic> json) {
    return YearSchedule(
      year: _parseInt(json['year']),
      totalDays: _parseInt(json['total_days']),
      totalWorkdays: _parseInt(json['total_workdays']),
      schedules: (json['schedules'] as List<dynamic>)
          .map((e) => ScheduleItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  // Helper yang fleksibel: terima int, num, atau String
  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      return int.tryParse(v) ?? 0;
    }
    return 0;
  }
}