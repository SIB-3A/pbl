import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/schedule_service.dart';
import '../models/schedule_model.dart';
import '../utils/api_wrapper.dart';
import '../widgets/schedule_calendar.dart';
import '../widgets/legend_item.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  Map<DateTime, ScheduleItem> scheduleMap = {};
  ApiResponse<YearSchedule>? response;
  String message = '';
  bool loading = true;
  late Timer _timer;
  late DateTime _now;
  bool localeReady = false;

  final Color headerColor = const Color(0xFF22A9D6);
  final Color greenWork = const Color(0xFF65AD05);
  final Color redOut = const Color(0xFFD53030);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() => localeReady = true);
    });
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    loadSchedule();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> loadSchedule() async {
    setState(() => loading = true);
    final res = await ScheduleService().getYearSchedule(selectedYear);
    setState(() {
      response = res;
      if (res.success && res.data != null) {
        scheduleMap = {
          for (var item in res.data!.schedules)
            DateTime.parse(item.date).toLocalDateOnly(): item,
        };
      }

      loading = false;
    });
  }

  Future<void> _addHoliday() async {
    final rootContext = context;
    DateTime? selectedDate;
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Tambah Libur Custom'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Libur',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(selectedYear),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2040),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
                child: Text(
                  selectedDate == null
                      ? 'Pilih Tanggal'
                      : DateFormat(
                          'dd MMMM yyyy',
                          'id_ID',
                        ).format(selectedDate!),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed:
                  (selectedDate != null && nameController.text.isNotEmpty)
                  ? () async {
                      Navigator.pop(dialogContext);
                      final res = await ScheduleService().addHoliday(
                        date: DateFormat('yyyy-MM-dd').format(selectedDate!),
                        name: nameController.text,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(rootContext).showSnackBar(
                        SnackBar(
                          content: Text(res.message),
                          backgroundColor: res.success
                              ? Colors.green
                              : Colors.red,
                        ),
                      );
                      if (res.success) {
                        setState(() {
                          final date = DateFormat(
                            'yyyy-MM-dd',
                          ).format(selectedDate!);

                          scheduleMap[DateTime.parse(
                            date,
                          ).toLocalDateOnly()] = ScheduleItem(
                            date: date,
                            isWorkday: false,
                            holidayName: nameController.text,
                            dayOfWeek: "",
                          );
                        });
                      }
                    }
                  : null,
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime day) {
    final item = scheduleMap[day.toLocalDateOnly()];
    if (item == null) return;

    String title = item.isWorkday ? 'Hari Kerja' : 'Libur';
    String subtitle = item.holidayName ?? 'Akhir Pekan';
    IconData icon = item.isWorkday ? Icons.work : Icons.event_busy;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd MMMM yyyy', 'id_ID').format(day),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.dayOfWeek, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (!item.isWorkday)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!localeReady || loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!response!.success || response!.data == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
              Text(response!.message),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loadSchedule,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),
        ),
      );
    }

    final s = response!.data!;
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("JADWAL KERJA"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadSchedule,
            tooltip: "Refresh",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // HEADER TANGGAL + JAM
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  dateFormat.format(_now),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  timeFormat.format(_now),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // TOMBOL TAMBAH LIBUR (ADMIN)
          Card(
            color: Colors.orange[50],
            child: ListTile(
              leading: const Icon(
                Icons.add_circle_outline,
                color: Colors.orange,
              ),
              title: const Text(
                "Tambah Libur Custom",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _addHoliday,
            ),
          ),

          const SizedBox(height: 16),

          // TOTAL HARI KERJA
          Card(
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "${s.totalWorkdays}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Hari Kerja",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // LEGENDA
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  LegendItem(
                    icon: Icons.work,
                    color: Colors.blue,
                    label: "Hari Kerja",
                  ),
                  LegendItem(
                    icon: Icons.event_busy,
                    color: Colors.red,
                    label: "Libur",
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // KALENDER
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ScheduleCalendar(
                selectedYear: selectedYear,
                selectedMonth: selectedMonth,
                scheduleMap: scheduleMap,
                onDaySelected: (day) => _showDayDetails(context, day),
                onPageChanged: (focusedDay) {
                  setState(() {
                    if (selectedYear != focusedDay.year) {
                      selectedYear = focusedDay.year;
                      loadSchedule();
                    }
                    selectedMonth = focusedDay.month;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "Kalender Jadwal Kerja",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
