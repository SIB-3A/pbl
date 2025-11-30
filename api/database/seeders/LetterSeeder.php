<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class LetterSeeder extends Seeder
{
    public function run()
    {
        $now = Carbon::now();
        $data = [];

        for ($i = 0; $i < 10; $i++) {

            $employeeId = 3 + $i;

            $requestDate = $now->copy()->subDays(rand(5, 20));
            $startDate   = $requestDate->copy()->addDays(rand(1, 5));
            $endDate     = $startDate->copy()->addDays(rand(2, 7));

            $status = rand(0, 2); // 0 = pending, 1 = approved, 2 = rejected

            // Logic baru:
            // status 1 atau 2 => approved_by = 1
            // status 0 => approved_by = null
            $approvedBy = ($status === 1 || $status === 2) ? 1 : null;

            // approved_at hanya diisi jika status 1 (approved)
            $approvedAt = ($status === 1)
                ? $now->copy()->subDays(rand(1, 3))
                : null;

            $data[] = [
                'letter_format_id'      => rand(1, 3),
                'employee_id'           => $employeeId,
                'title'                 => 'Permohonan Surat ' . ($i + 1),
                'status'                => $status,
                'request_date'          => $requestDate,
                'effective_start_date'  => $startDate,
                'effective_end_date'    => $endDate,
                'notes'                 => 'Keterangan tambahan untuk surat ke-' . ($i + 1),
                'approved_by'           => $approvedBy,
                'approved_at'           => $approvedAt,
                'created_at'            => $now,
                'updated_at'            => $now,
            ];
        }

        DB::table('letters')->insert($data);
    }
}
