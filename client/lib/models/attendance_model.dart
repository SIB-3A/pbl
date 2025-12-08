class AttendanceStatus {
  final String hariIni;
  final String hari;
  final String status;
  final String? liburNama;
  final String employee;
  final String? tipeAbsen;
  final bool sudahClockIn;
  final String? clockInTime;
  final String? clockOutTime;
  final String? statusAbsen;
  final String? lemburMulai;      
  final String? lemburSelesai;    

  AttendanceStatus({
    required this.hariIni,
    required this.hari,
    required this.status,
    this.liburNama,
    required this.employee,
    this.tipeAbsen,
    required this.sudahClockIn,
    this.clockInTime,
    this.clockOutTime,
    this.statusAbsen,
    this.lemburMulai,
    this.lemburSelesai,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) {
    return AttendanceStatus(
      hariIni: json['hari_ini'] ?? '',
      hari: json['hari'] ?? '',
      status: json['status'] ?? '',
      liburNama: json['libur_nama'],
      employee: json['employee'] ?? '',
      tipeAbsen: json['tipe_absen'],
      sudahClockIn: json['sudah_clock_in'] ?? false,
      clockInTime: json['clock_in_time'],
      clockOutTime: json['clock_out_time'],
      statusAbsen: json['status_absen'],
      lemburMulai: json['lembur_mulai'],      
      lemburSelesai: json['lembur_selesai'],
    );
  }
}