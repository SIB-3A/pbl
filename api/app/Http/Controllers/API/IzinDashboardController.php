<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
use PhpOffice\PhpSpreadsheet\Style\Border;
use PhpOffice\PhpSpreadsheet\Style\Fill;

class IzinDashboardController extends Controller
{
    public function __invoke()
    {
        // Total karyawan yang sudah mengajukan minimal 1 surat
        $employeesWithLetters = DB::table('letters')
            ->distinct('employee_id')
            ->count('employee_id');

        $totalEmployees = DB::table('employees')->count();

        $totalLettersApproved = DB::table('letters')
            ->where('status', 1)
            ->count();

        $totalLetters = DB::table('letters')->count();

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

        $allLetters = DB::table('letters')
            ->join('employees', 'employees.id', '=', 'letters.employee_id')
            ->leftJoin('departments', 'departments.id', '=', 'employees.department_id')
            ->leftJoin('letter_formats', 'letter_formats.id', '=', 'letters.letter_format_id')
            ->where('letters.status', 1)
            ->select(
                'employees.id as employee_id',
                DB::raw("CONCAT(employees.first_name, ' ', employees.last_name) AS employee_name"),
                'departments.name as department_name',
                DB::raw("COUNT(letters.id) as total_approved_letters"),
                DB::raw("GROUP_CONCAT(DISTINCT letter_formats.name SEPARATOR ', ') as cuti_list")
            )
            ->groupBy(
                'employees.id',
                'employees.first_name',
                'employees.last_name',
                'departments.name'
            )
            ->orderBy('employee_name', 'ASC')
            ->get();

        return response()->json([
            'total_employees_with_letters' => $employeesWithLetters,
            'total_employees' => $totalEmployees,
            'total_letters_approved' => $totalLettersApproved,
            'total_letters' => $totalLetters,
            'departments' => $departments,
            'all_letters' => $allLetters,
        ]);
    }


    public function exportApprovedLetters()
    {
        $data = DB::table('letters')
            ->join('employees', 'employees.id', '=', 'letters.employee_id')
            ->leftJoin('departments', 'departments.id', '=', 'employees.department_id')
            ->leftJoin('letter_formats', 'letter_formats.id', '=', 'letters.letter_format_id')
            ->where('letters.status', 1)
            ->select(
                DB::raw("CONCAT(employees.first_name, ' ', employees.last_name) AS employee_name"),
                'departments.name as department_name',
                DB::raw("COUNT(letters.id) as total_approved_letters"),
                DB::raw("GROUP_CONCAT(DISTINCT letter_formats.name SEPARATOR ', ') as cuti_list")
            )
            ->groupBy(
                'employees.id',
                'employees.first_name',
                'employees.last_name',
                'departments.name'
            )
            ->orderBy('employee_name', 'ASC')
            ->get();

        // EXCEL ----------------------------------------------------
        $spreadsheet = new Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();

        // HEADER
        $sheet->setCellValue('A1', 'Nama Karyawan');
        $sheet->setCellValue('B1', 'Departemen');
        $sheet->setCellValue('C1', 'Total Cuti Disetujui');
        $sheet->setCellValue('D1', 'Jenis Cuti');

        // STYLE HEADER
        $headerStyle = [
            'font' => ['bold' => true],
            'fill' => [
                'fillType' => \PhpOffice\PhpSpreadsheet\Style\Fill::FILL_SOLID,
                'startColor' => ['rgb' => 'DDDDDD']
            ],
            'borders' => [
                'allBorders' => [
                    'borderStyle' => \PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN
                ]
            ]
        ];

        $sheet->getStyle('A1:D1')->applyFromArray($headerStyle);

        // DATA
        $row = 2;
        foreach ($data as $item) {
            $sheet->setCellValue("A{$row}", $item->employee_name);
            $sheet->setCellValue("B{$row}", $item->department_name);
            $sheet->setCellValue("C{$row}", $item->total_approved_letters);
            $sheet->setCellValue("D{$row}", $item->cuti_list);
            $row++;
        }

        // BORDER FULL TABLE
        $sheet->getStyle("A1:D" . ($row - 1))
            ->getBorders()->getAllBorders()->setBorderStyle(
                \PhpOffice\PhpSpreadsheet\Style\Border::BORDER_THIN
            );

        // AUTO SIZE
        foreach (range('A', 'D') as $col) {
            $sheet->getColumnDimension($col)->setAutoSize(true);
        }

        // SAVE FILE
        $fileName = "laporan_cuti_disetujui.xlsx";
        $filePath = storage_path("app/public/{$fileName}");
        
        $writer = new Xlsx($spreadsheet);
        $writer->save($filePath);

        return response()->download($filePath, $fileName)->deleteFileAfterSend(true);
    }

}
