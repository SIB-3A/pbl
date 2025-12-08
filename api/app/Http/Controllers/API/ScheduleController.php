<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Holiday;
use App\Helpers\ResponseWrapper;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ScheduleController extends Controller
{
    /**
     * Get workday + holiday schedule for a given year
     */
    public function getYearSchedule(Request $request, $year = null)
    {
        try {
            $year = $year ?? now()->year;

            // Validasi tahun
            if ($year < 2020 || $year > 2040) {
                return ResponseWrapper::make(
                    message: 'Tahun tidak valid. Gunakan 2020 - 2040.',
                    status: 400,
                    success: false,
                    data: null,
                    errors: ['year' => 'Tahun di luar rentang yang diizinkan']
                );
            }

            // Ambil daftar libur dalam tahun tsb
            $holidays = Holiday::whereYear('date', $year)->get();

            // Convert ke array string date untuk memudahkan pengecekan
            $holidayDates = $holidays
                ->pluck('date')
                ->map(fn ($d) => $d->format('Y-m-d'))
                ->toArray();

            // Date range
            $startDate = Carbon::createFromDate($year, 1, 1);
            $endDate   = Carbon::createFromDate($year, 12, 31);

            $schedules = [];

            // Loop semua tanggal dalam satu tahun
            for ($date = $startDate->copy(); $date->lte($endDate); $date->addDay()) {

                $formattedDate = $date->format('Y-m-d');
                $dayOfWeekNumber = $date->dayOfWeek; // 0=Sun, 6=Sat

                // Workday = Monday–Friday & bukan libur
                $isWorkday = ($dayOfWeekNumber >= 1 && $dayOfWeekNumber <= 5)
                            && !in_array($formattedDate, $holidayDates);

                // Ambil libur jika ada
                $holiday = $holidays->first(
                    fn ($h) => $h->date->format('Y-m-d') === $formattedDate
                );

                $holidayName = $holiday?->name;

                // Tentukan jenis libur
                $holidayType = $holidayName
                    ? (str_contains($holidayName, '(Libur Nasional)') ? 'Nasional' : 'Cuti Bersama')
                    : null;

                // Tambah ke schedule
                $schedules[] = [
                    'date'          => $formattedDate,
                    'day_of_week'   => $date->translatedFormat('l'),
                    'is_workday'    => $isWorkday,
                    'holiday_name'  => $holidayName,
                    'holiday_type'  => $holidayType,
                ];
            }

            // Hitung total hari kerja
            $totalWorkdays = count(
                array_filter($schedules, fn ($s) => $s['is_workday'])
            );

            return ResponseWrapper::make(
                message: "Jadwal tahun $year berhasil dimuat",
                status: 200,
                success: true,
                data: [
                    'year'           => $year,
                    'total_days'     => count($schedules),
                    'total_workdays' => $totalWorkdays,
                    'schedules'      => $schedules,
                ],
                errors: null
            );

        } catch (\Exception $e) {

            \Log::error('Schedule ERROR: ' . $e->getMessage());

            return ResponseWrapper::make(
                message: 'Terjadi kesalahan saat memuat jadwal',
                status: 500,
                success: false,
                data: null,
                errors: ['exception' => $e->getMessage()]
            );
        }
    }

    /**
     * Add custom holiday
     */
    public function addHoliday(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'date' => 'required|date|date_format:Y-m-d|after_or_equal:2025-01-01|before_or_equal:2040-12-31',
            'name' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return ResponseWrapper::make(
                message: 'Validasi gagal',
                status: 422,
                success: false,
                data: null,
                errors: $validator->errors()->toArray()
            );
        }

        // Cek jika sudah ada libur di tanggal itu
        $existing = Holiday::where('date', $request->date)->first();

        if ($existing) {
            return ResponseWrapper::make(
                message: "Tanggal sudah ada libur: {$existing->name}",
                status: 409,
                success: false,
                data: null,
                errors: null
            );
        }

        // Tambah libur baru
        $holiday = Holiday::create([
            'date'        => $request->date,
            'name'        => $request->name . ' (Libur Custom)',
            'description' => null,
        ]);

        return ResponseWrapper::make(
            message: 'Libur berhasil ditambahkan!',
            status: 201,
            success: true,
            data: $holiday->toArray(),
            errors: null
        );
    }
}
