<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseWrapper;
use App\Http\Controllers\Controller;
use App\Models\Employee;

class EmployeeController extends Controller
{
    /**
     * Display a listing of employees.
     */
    public function index()
    {
        $employees = Employee::with(['user', 'position', 'department'])->get();
        
        return ResponseWrapper::make(
            "Daftar karyawan berhasil diambil",
            200,
            true,
            ["employees" => $employees],
            null
        );
    }

    /**
     * Display the specified employee.
     */
    public function show(string $id)
    {
        $employee = Employee::with(['user', 'position', 'department'])->find($id);
        
        if (!$employee) {
            return ResponseWrapper::make(
                "Karyawan tidak ditemukan",
                404,
                false,
                null,
                null
            );
        }
        
        return ResponseWrapper::make(
            "Data karyawan berhasil ditemukan",
            200,
            true,
            ["employee" => $employee],
            null
        );
    }
}