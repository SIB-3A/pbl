import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/schedule_model.dart';

class ScheduleCalendar extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final Map<DateTime, ScheduleItem> scheduleMap;
  final Function(DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const ScheduleCalendar({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.scheduleMap,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  Color? _getCellColor(DateTime day) {
    final item = scheduleMap[day.toLocalDateOnly()];
    if (item == null) return Colors.grey[200];
    return item.isWorkday ? Colors.blue[100] : Colors.red[100];
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(selectedYear, 1, 1),
      lastDay: DateTime(selectedYear, 12, 31),
      focusedDay: DateTime(selectedYear, selectedMonth, 15),
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final color = _getCellColor(day);
          final isToday = isSameDay(day, DateTime.now());
          final item = scheduleMap[day.toLocalDateOnly()];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isToday ? Colors.orange.withOpacity(0.3) : color?.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isToday ? Colors.orange : Colors.transparent, width: 2),
            ),
            child: Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontWeight: item?.holidayName != null || isToday ? FontWeight.bold : FontWeight.normal,
                  color: color != null ? (color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white) : null,
                ),
              ),
            ),
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) => onDaySelected(selectedDay),
      onPageChanged: onPageChanged,
      eventLoader: (day) => scheduleMap.containsKey(day.toLocalDateOnly()) ? [1] : [],
    );
  }
}

extension DateTimeExtension on DateTime {
  DateTime toLocalDateOnly() => DateTime(year, month, day);
}

bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;