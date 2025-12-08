import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/attendance_service.dart';
import '../models/attendance_model.dart';
import '../utils/api_wrapper.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  ApiResponse<AttendanceStatus>? statusResponse;
  String message = '';
  bool loading = true;
  late Timer _timer;
  late DateTime _now;
  bool localeReady = false;

  final Color headerColor = const Color(0xFF22A9D6);
  final Color greenWork = const Color(0xFF65AD05);
  final Color redOut = const Color(0xFFD53030);
  final Color overtimeColor = const Color(0xFFFCEA10);

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
    loadStatus();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> loadStatus() async {
    setState(() => loading = true);
    final res = await AttendanceService().getStatus();
    setState(() {
      statusResponse = res;
      loading = false;
    });
  }

  Future<void> action(Future<ApiResponse<Map<String, dynamic>>> Function() apiCall) async {
    final res = await apiCall();
    setState(() {
      message = res.success ? res.message : " ${res.message}";
    });
    await loadStatus(); 
  }

  @override
  Widget build(BuildContext context) {
    if (!localeReady || loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // CEK RESPONSE SUKSES
    if (!statusResponse!.success || statusResponse!.data == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
              const Text("Gagal memuat data", style: TextStyle(fontSize: 18)),
              Text(statusResponse!.message),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: loadStatus,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),
        ),
      );
    }

    final s = statusResponse!.data!;
    final isLibur = s.status.contains('Libur');
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("HRIS ATTENDANCE"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: loadStatus,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // HEADER TANGGAL + JAM REAL-TIME
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
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
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

            // CARD UTAMA
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + Nama
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, size: 36, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Karyawan", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(s.employee, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Status Hari
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: isLibur ? redOut : greenWork, size: 22),
                        const SizedBox(width: 12),
                        const Text("Status Hari", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isLibur ? redOut : greenWork,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            s.status,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // MESSAGE
                    if (message.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusResponse!.success ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: statusResponse!.success ? Colors.green[900] : Colors.red[900],
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,  
                        ),
                      ),

                    const SizedBox(height: 20),

                    // TOMBOL ABSEN REGULER
                    if (!isLibur && !s.sudahClockIn)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => action(() => AttendanceService().clockIn()),
                          icon: const Icon(Icons.fingerprint, size: 32),
                          label: const Text("Absen Masuk", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenWork,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 6,
                          ),
                        ),
                      ),

                    if (!isLibur && s.sudahClockIn && s.clockOutTime == null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => action(() => AttendanceService().clockOut()),
                          icon: const Icon(Icons.logout, size: 28),
                          label: const Text("Absen Keluar", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redOut,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),

                    // MULAI LEMBUR
                    if ((!isLibur && s.clockOutTime != null && s.lemburMulai == null) || (isLibur && s.lemburMulai == null))
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => action(() => AttendanceService().lemburIn()),
                          icon: const Icon(Icons.work, size: 28),
                          label: const Text("Mulai Lembur", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: overtimeColor,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),

                    if (s.lemburMulai != null && s.lemburSelesai == null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => action(() => AttendanceService().lemburOut()),
                          icon: const Icon(Icons.work_off, size: 28),
                          label: const Text("Selesai Lembur", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redOut,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}