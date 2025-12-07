<?php

namespace App\Http\Controllers\API;

use App\Helpers\ResponseWrapper;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;

class IzinDashboardController extends Controller
{
    public function __invoke(Request $request)
    {
        try {
            // Hitung data utama dashboard
            $employeesWithLetters = DB::table('letters')->distinct('employee_id')->count('employee_id');
            $totalEmployees = DB::table('employees')->count();
            $totalLettersApproved = DB::table('letters')->where('status', 1)->count();
            $totalLetters = DB::table('letters')->count();
            $totalApprovedOrRejected = DB::table('letters')->whereIn('status', [1, 2])->count();
            $totalPending = DB::table('letters')->where('status', 0)->count();

            // Data departemen
            $departments = DB::table('departments')
                ->leftJoin('employees', 'employees.department_id', '=', 'departments.id')
                ->leftJoin('letters', 'letters.employee_id', '=', 'employees.id')
                ->select(
                    'departments.id',
                    'departments.name',
                    DB::raw('COUNT(DISTINCT employees.id) as total_karyawan'),
                    DB::raw('COUNT(letters.id) as total_izin')
                )
                ->groupBy('departments.id', 'departments.name')
                ->get()
                ->map(function ($dept) {
                    return [
                        'name'  => $dept->name,
                        'count' => "{$dept->total_izin} / {$dept->total_karyawan}"
                    ];
                });

            // Filter bulan
            $month = (int) $request->query('month', 0);

            $lettersQuery = DB::table('letters')
                ->join('employees', 'employees.id', '=', 'letters.employee_id')
                ->leftJoin('departments', 'departments.id', '=', 'employees.department_id')
                ->leftJoin('letter_formats', 'letter_formats.id', '=', 'letters.letter_format_id')
                ->where('letters.status', 1);

            if ($month >= 1 && $month <= 12) {
                $lettersQuery->whereMonth('letters.request_date', $month);
            }

            $allLetters = $lettersQuery
                ->select(
                    'employees.id as employee_id',
                    DB::raw("CONCAT(employees.first_name, ' ', employees.last_name) AS employee_name"),
                    'departments.name as department_name',
                    DB::raw("COUNT(letters.id) as total_approved_letters"),
                    DB::raw("GROUP_CONCAT(letter_formats.name SEPARATOR ', ') as cuti_list"),
                    DB::raw("GROUP_CONCAT(letters.request_date ORDER BY letters.request_date SEPARATOR ',') as cuti_dates")
                )
                ->groupBy(
                    'employees.id',
                    'employees.first_name',
                    'employees.last_name',
                    'departments.name'
                )
                ->orderBy('employee_name', 'ASC')
                ->get();

            // ✔ Kembalikan pakai ResponseWrapper
            return ResponseWrapper::make(
                "Dashboard berhasil dimuat",
                200,
                true,
                [
                    'total_employees_with_letters'       => $employeesWithLetters,
                    'total_employees'                    => $totalEmployees,
                    'total_letters_approved'             => $totalLettersApproved,
                    'total_letters'                      => $totalLetters,
                    'departments'                        => $departments,
                    'all_letters'                        => $allLetters,
                    'total_letters_approved_or_rejected' => $totalApprovedOrRejected,
                    'total_letters_pending'              => $totalPending,
                ],
                null
            );
        } catch (\Exception $e) {
            return ResponseWrapper::make(
                "Terjadi kesalahan pada server",
                500,
                false,
                null,
                $e->getMessage()
            );
        }
    }

    public function izinList()
    {
        try {

            $data = DB::table('letters')
                ->join('employees', 'employees.id', '=', 'letters.employee_id')
                ->leftJoin('positions', 'positions.id', '=', 'employees.position_id')
                ->leftJoin('departments', 'departments.id', '=', 'employees.department_id')
                ->leftJoin('letter_formats', 'letter_formats.id', '=', 'letters.letter_format_id')
                ->select(
                    'letters.id',
                    'letters.status',

                    // tanggal
                    DB::raw("DATE_FORMAT(letters.request_date, '%d/%m/%Y') AS date"),

                    // fullname
                    DB::raw("CONCAT(employees.first_name, ' ', employees.last_name) AS full_name"),

                    // jabatan
                    'positions.name as position',

                    // department
                    'departments.name as department_name',

                    // nama surat
                    'letter_formats.name as letter_name'
                )
                ->orderBy('letters.request_date', 'DESC')
                ->get();

            return ResponseWrapper::make(
                "Berhasil mengambil list izin",
                200,
                true,
                $data,
                null
            );
        } catch (\Exception $e) {
            return ResponseWrapper::make(
                "Gagal mengambil list izin",
                500,
                false,
                null,
                $e->getMessage()
            );
        }
    }

    public function updateStatus(Request $request, $id)
    {
        try {
            $status = $request->status;

            if (!in_array($status, [0, 1, 2])) {
                return ResponseWrapper::make(
                    "Status tidak valid",
                    400,
                    false,
                    null,           // data
                    null            // errors
                );
            }

            DB::table('letters')
                ->where('id', $id)
                ->update([
                    'status' => $status
                ]);

            return ResponseWrapper::make(
                "Status berhasil diperbarui",
                200,
                true,
                null,           // data
                null            // errors
            );
        } catch (\Exception $e) {
            return ResponseWrapper::make(
                "Gagal memperbarui status",
                500,
                false,
                null,                // data
                $e->getMessage()     // errors
            );
        }
    }




    public function exportApprovedLetters(Request $request)
    {
        try {
            $month = (int) $request->query('month', 0);

            $query = DB::table('letters')
                ->join('employees', 'employees.id', '=', 'letters.employee_id')
                ->leftJoin('departments', 'departments.id', '=', 'employees.department_id')
                ->leftJoin('letter_formats', 'letter_formats.id', '=', 'letters.letter_format_id')
                ->where('letters.status', 1);

            if ($month >= 1 && $month <= 12) {
                $query->whereMonth('letters.request_date', $month);
            }

            $data = $query
                ->select(
                    DB::raw("CONCAT(employees.first_name, ' ', employees.last_name) AS employee_name"),
                    'departments.name as department_name',
                    DB::raw("COUNT(letters.id) as total_approved_letters"),
                    DB::raw("GROUP_CONCAT(letter_formats.name ORDER BY letter_formats.name SEPARATOR ',') as cuti_list"),
                    DB::raw("GROUP_CONCAT(letters.request_date ORDER BY letters.request_date SEPARATOR ',') as cuti_dates")
                )
                ->groupBy(
                    'employees.id',
                    'employees.first_name',
                    'employees.last_name',
                    'departments.name'
                )
                ->orderBy('employee_name', 'ASC')
                ->get();

            // --- Generate Excel ---
            $spreadsheet = new Spreadsheet();
            $sheet = $spreadsheet->getActiveSheet();

            $sheet->setCellValue('A1', 'Nama Karyawan');
            $sheet->setCellValue('B1', 'Departemen');
            $sheet->setCellValue('C1', 'Total Cuti Disetujui');
            $sheet->setCellValue('D1', 'Jenis Cuti + Tanggal');

            $sheet->getStyle('A1:D1')->applyFromArray([
                'font' => ['bold' => true],
                'fill' => [
                    'fillType' => Fill::FILL_SOLID,
                    'startColor' => ['rgb' => 'DDDDDD']
                ],
                'borders' => [
                    'allBorders' => ['borderStyle' => Border::BORDER_THIN]
                ]
            ]);

            $row = 2;
            foreach ($data as $item) {

                $cutiList = explode(',', $item->cuti_list);
                $cutiDates = explode(',', $item->cuti_dates);

                $combined = [];
                foreach ($cutiList as $index => $cutiName) {
                    $date = $cutiDates[$index] ?? '-';
                    $combined[] = "{$cutiName} ({$date})";
                }

                $sheet->setCellValue("A{$row}", $item->employee_name);
                $sheet->setCellValue("B{$row}", $item->department_name);
                $sheet->setCellValue("C{$row}", $item->total_approved_letters);
                $sheet->setCellValue("D{$row}", implode(", ", $combined));

                $row++;
            }

            foreach (range('A', 'D') as $col) {
                $sheet->getColumnDimension($col)->setAutoSize(true);
            }

            $fileName = "laporan_cuti_disetujui.xlsx";
            $filePath = storage_path("app/public/{$fileName}");

            $writer = new Xlsx($spreadsheet);
            $writer->save($filePath);

            return response()->download($filePath)->deleteFileAfterSend(true);
        } catch (\Exception $e) {
            return ResponseWrapper::make(
                "Gagal mengekspor Excel",
                500,
                false,
                null,
                $e->getMessage()
            );
        }
    }
}
