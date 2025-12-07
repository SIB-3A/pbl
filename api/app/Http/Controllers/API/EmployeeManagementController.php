<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseWrapper;
use App\Http\Controllers\Controller;
use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Throwable;

class EmployeeManagementController extends Controller
{
    /**
     * Update employee management data (by admin).
     * Only updates: employment_status, position_id, department_id
     */
    public function update(Request $request, string $id)
    {
        $employee = Employee::find($id);
        
        if (!$employee) {
            return ResponseWrapper::make(
                "Karyawan tidak ditemukan",
                404,
                false,
                null,
                null
            );
        }

        // TODO: Add admin authorization check
        // if (!$request->user()->is_admin) {
        //     return ResponseWrapper::make(
        //         "Anda tidak memiliki akses admin",
        //         403,
        //         false,
        //         null,
        //         null
        //     );
        // }

        try {
            $validated = $request->validate([
                "employment_status" => "sometimes|required|in:aktif,cuti,resign,phk",
                "position_id" => "sometimes|nullable|integer|exists:positions,id",
                "department_id" => "sometimes|nullable|integer|exists:departments,id",
            ]);

            DB::beginTransaction();

            $employee->update($validated);

            DB::commit();

            $employee->load(['user', 'position', 'department']);

            return ResponseWrapper::make(
                "Data manajemen karyawan berhasil diperbarui",
                200,
                true,
                ["employee" => $employee],
                null
            );

        } catch (ValidationException $e) {
            return ResponseWrapper::make(
                "Validasi gagal",
                422,
                false,
                null,
                $e->errors()
            );

        } catch (Throwable $e) {
            DB::rollBack();

            Log::error('Employee management update failed', [
                'employee_id' => $employee->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal memperbarui data manajemen karyawan",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );
        }
    }
}