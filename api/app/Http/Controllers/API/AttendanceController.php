<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\CheckClock;
use App\Models\Employee;
use App\Models\Holiday;
use App\Helpers\ResponseWrapper;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AttendanceController extends Controller
{
    // Clock In Reguler
    public function clockIn(Request $request)
    {
        $request->validate([
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = $request->user();
        $employee = $user->employee;

        $today = Carbon::today();

        // Cek hari libur
        $dayName = $today->translatedFormat('l');
        $isHoliday = Holiday::where('date', $today)->exists();
        $isWeekend = in_array($dayName, ['Saturday', 'Sunday']);

        if ($isHoliday || $isWeekend) {
            return ResponseWrapper::make(
                message: 'Hari ini libur! Tidak bisa absen reguler.',
                status: 403,
                success: false,
                data: null,
                errors: null
            );
        }

        if (!$employee) {
            return ResponseWrapper::make(
                message: "Employee dengan ID $employee->id tidak ditemukan!",
                status: 404,
                success: false,
                data: ['available_ids' => Employee::pluck('id')->toArray()],
                errors: null
            );
        }

        $distance = haversine_distance(
            $employee->department->latitude,
            $employee->department->longitude,
            $request->latitude,
            $request->longitude
        );

        if ($distance > $employee->department->radius_meters) {
            return ResponseWrapper::make(
                message: 'Gagal absensi. Anda di luar radius perusahaan!',
                status: 403,
                success: false,
                data: [
                    'jarak_meter' => round($distance),
                    'batas' => $employee->department->radius_meters
                ],
                errors: null
            );
        }

        $existing = CheckClock::where('employee_id', $employee->id)
            ->where('check_clock_type', 0)
            ->where('date', $today)
            ->first();

        if ($existing?->clock_in) {
            return ResponseWrapper::make(
                message: 'Kamu sudah Clock In hari ini jam ' . $existing->clock_in,
                status: 400,
                success: false,
                data: null,
                errors: null
            );
        }

        CheckClock::updateOrCreate(
            [
                'employee_id' => $employee->id,
                'check_clock_type' => 0,
                'date' => $today,
            ],
            [
                'clock_in' => now()->format('H:i:s'),
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
                'accuracy_meters' => round($distance),
            ]
        );

        return ResponseWrapper::make(
            message: 'Clock In berhasil!',
            status: 200,
            success: true,
            data: [
                'waktu' => now()->format('H:i'),
                'status' => 'Menunggu Clock Out...'
            ],
            errors: null
        );
    }

    // Clock Out Reguler
    public function clockOut(Request $request)
    {
        $user = $request->user();
        $employee = $user->employee;

        if (!$employee || !$employee->department) {
            return ResponseWrapper::make('Employee atau department tidak ditemukan!', 404, false, null, null);
        }

        $today = Carbon::today();
        $clock = CheckClock::where('employee_id', $employee->id)
            ->where('check_clock_type', 0)
            ->where('date', $today)
            ->first();

        if (!$clock) {
            return ResponseWrapper::make('Kamu belum Clock In hari ini!', 400, false, null, null);
        }

        if ($clock->clock_out) {
            return ResponseWrapper::make('Sudah Clock Out jam ' . $clock->clock_out, 400, false, null, null);
        }

        $latitude  = $request->input('latitude');
        $longitude = $request->input('longitude');

        if ($latitude !== null && $longitude !== null) {
            $lat = floatval($latitude);
            $lon = floatval($longitude);

            $distance = haversine_distance(
                floatval($employee->department->latitude),
                floatval($employee->department->longitude),
                $lat,
                $lon
            );

            if ($distance > $employee->department->radius_meters) {
                return ResponseWrapper::make('Clock Out di luar radius kantor!', 403, false, [
                    'jarak_meter' => round($distance),
                    'batas' => $employee->department->radius_meters . ' meter'
                ], null);
            }

            \DB::table('check_clocks')
                ->where('id', $clock->id)
                ->update([
                    'clock_out'       => '16:00:00',
                    'latitude'        => $lat,
                    'longitude'       => $lon,
                    'accuracy_meters' => (int) round($distance),
                    'updated_at'      => now(),
                ]);
        } else {
            \DB::table('check_clocks')
                ->where('id', $clock->id)
                ->update([
                    'clock_out'  => '16:00:00',
                    'updated_at' => now(),
                ]);
        }

        // Hitung jam kerja
        $in = Carbon::createFromTimeString($clock->clock_in);
        $out = Carbon::createFromTimeString('16:00:00');
        $durasi = $out->diffInMinutes($in) / 60;

        $clock->refresh();

        return ResponseWrapper::make(
            message: 'Clock Out berhasil! Pulang jam 16:00',
            status: 200,
            success: true,
            data: [
                'clock_in' => $clock->clock_in?->format('H:i'),
                'clock_out' => '16:00',
                'jarak_pulang' => $clock->accuracy_meters . ' meter dari kantor',
                'total_jam_kerja' => round($durasi, 2) . ' jam',
                'info' => 'GPS pulang tercatat'
            ],
            errors: null
        );
    }

    // Lembur In
    public function lemburIn(Request $request)
    {
        $request->validate([
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = $request->user();
        $employee = $user->employee;

        if (!$employee || !$employee->department) {
            return ResponseWrapper::make('Employee atau department tidak ditemukan!', 404, false, null, null);
        }

        $distance = haversine_distance(
            $employee->department->latitude,
            $employee->department->longitude,
            $request->latitude,
            $request->longitude
        );

        if ($distance > $employee->department->radius_meters) {
            return ResponseWrapper::make('Di luar radius kantor untuk lembur!', 403, false, [
                'jarak' => round($distance) . ' meter'
            ], null);
        }

        $today = Carbon::today();
        CheckClock::updateOrCreate(
            [
                'employee_id' => $employee->id,
                'check_clock_type' => 1,
                'date' => $today,
            ],
            [
                'overtime_start' => now()->format('H:i:s'),
                'latitude' => (float) $request->latitude,
                'longitude' => (float) $request->longitude,
                'accuracy_meters' => (int) round($distance),
            ]
        );

        return ResponseWrapper::make(
            message: 'Lembur dimulai!',
            status: 200,
            success: true,
            data: [
                'lembur_mulai' => now()->format('H:i'),
                'lembur_selesai' => null,
                'waktu_mulai' => now()->format('H:i'),
                'jarak_dari_kantor' => round($distance) . ' meter'
            ],
            errors: null
        );
    }

    // Lembur Out
    public function lemburOut(Request $request)
    {
        $request->validate([
            'latitude'  => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $user = $request->user();
        $employee = $user->employee;

        if (!$employee || !$employee->department) {
            return ResponseWrapper::make('Employee atau department tidak ditemukan!', 404, false, null, null);
        }

        $today = Carbon::today();
        $isHoliday = Holiday::where('date', $today)->exists();
        $isWeekend = in_array($today->translatedFormat('l'), ['Saturday', 'Sunday']);
        $isLibur = $isHoliday || $isWeekend;

        $lembur = CheckClock::where('employee_id', $employee->id)
            ->where('check_clock_type', 1)
            ->where('date', $today)
            ->whereNotNull('overtime_start')
            ->firstOrFail();

        if ($lembur->overtime_end) {
            return ResponseWrapper::make('Lembur sudah selesai jam ' . $lembur->overtime_end, 400, false, null, null);
        }

        $distance = haversine_distance(
            (float) $employee->department->latitude,
            (float) $employee->department->longitude,
            (float) $request->latitude,
            (float) $request->longitude
        );

        if ($distance > $employee->department->radius_meters) {
            return ResponseWrapper::make('Lembur Out di luar radius kantor!', 403, false, [
                'jarak_meter' => round($distance),
                'batas' => $employee->department->radius_meters . ' meter'
            ], null);
        }

        $jamPulang = $isLibur ? '16:00:00' : '20:00:00';

        \DB::statement("
            UPDATE check_clocks 
            SET 
                overtime_end = ?,
                latitude = ?,
                longitude = ?,
                accuracy_meters = ?,
                updated_at = NOW()
            WHERE id = ?
        ", [
            $jamPulang,
            (float) $request->latitude,
            (float) $request->longitude,
            (int) round($distance),
            $lembur->id
        ]);

        // Hitung durasi lembur
        $start = Carbon::createFromTimeString($lembur->fresh()->overtime_start);
        $end = Carbon::parse($jamPulang);
        $durasiMenit = $start->diffInMinutes($end);

        return ResponseWrapper::make(
            message: 'Lembur selesai!',
            status: 200,
            success: true,
            data: [
                'selesai' => $jamPulang,
                'info' => $isLibur ? 'Hari libur → pulang jam 16:00' : 'Hari kerja → maks jam 20:00',
                'total_durasi_lembur' => round($durasiMenit / 60, 2) . ' jam',
            ],
            errors: null
        );
    }

    // Status Hari Ini
    public function statusHariIni(Request $request)
    {
        $user = $request->user();

        if (!$user) {
            return ResponseWrapper::make(
                message: 'Unauthorized. Token tidak valid atau tidak dikirim!',
                status: 401,
                success: false,
                data: null,
                errors: null
            );
        }

        $employee = $user->employee;

        if (!$employee) {
            return ResponseWrapper::make(
                message: 'Profile karyawan tidak ditemukan! Hubungi admin.',
                status: 404,
                success: false,
                data: null,
                errors: null
            );
        }

        if (!$employee->department) {
            return ResponseWrapper::make(
                message: 'Karyawan belum di-assign ke department!',
                status: 400,
                success: false,
                data: null,
                errors: null
            );
        }

        $today = Carbon::today();
        $dayName = $today->translatedFormat('l');

        $isHoliday = Holiday::where('date', $today)->exists();
        $isWeekend = in_array($dayName, ['Saturday', 'Sunday']);

        $clock = CheckClock::where('employee_id', $employee->id)
            ->where('check_clock_type', 0)
            ->where('date', $today)
            ->first();

        $lembur = CheckClock::where('employee_id', $employee->id)
            ->where('check_clock_type', 1)
            ->where('date', $today)
            ->first();

        $data = [
            'hari_ini' => $today->translatedFormat('d F Y'),
            'hari' => $dayName,
            'status' => $isHoliday ? 'Libur Nasional' : ($isWeekend ? 'Libur Akhir Pekan' : 'Hari Kerja'),
            'libur_nama' => $isHoliday ? Holiday::where('date', $today)->first()?->name : null,
            'employee' => $employee->first_name . ' ' . $employee->last_name,
            'sudah_clock_in' => $clock?->clock_in ? true : false,
            'clock_in_time' => $clock?->clock_in?->format('H:i') ?? null,
            'clock_out_time' => $clock?->clock_out?->format('H:i') ?? null,
            'status_absen' => $clock?->clock_in && !$clock?->clock_out
                ? 'Sudah masuk, belum pulang'
                : ($clock?->clock_out ? 'Sudah pulang' : 'Belum absen'),

            'lembur_mulai' => $lembur?->overtime_start
                ? Carbon::createFromTimeString($lembur->overtime_start)->format('H:i')
                : null,

            'lembur_selesai' => $lembur?->overtime_end
                ? Carbon::createFromTimeString($lembur->overtime_end)->format('H:i')
                : null,
        ];

        return ResponseWrapper::make(
            message: 'Status hari ini berhasil dimuat',
            status: 200,
            success: true,
            data: $data,
            errors: null
        );
    }
}
