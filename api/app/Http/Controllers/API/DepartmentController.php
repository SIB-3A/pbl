<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseWrapper;
use App\Http\Controllers\Controller;
use App\Models\Department;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Throwable;

class DepartmentController extends Controller
{
    /**
     * Display a listing of departments.
     */
    public function index()
    {
        $departments = Department::all();
        
        return ResponseWrapper::make(
            "Daftar departemen berhasil diambil",
            200,
            true,
            ["departments" => $departments],
            null
        );
    }

    /**
     * Store a newly created department.
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:100|unique:departments,name',
                'latitude' => 'required|numeric|between:-90,90',
                'longitude' => 'required|numeric|between:-180,180',
                'radius_meters' => 'required|integer|min:1|max:10000',
            ]);

            DB::beginTransaction();

            $department = Department::create($validated);

            DB::commit();

            return ResponseWrapper::make(
                "Departemen berhasil dibuat",
                201,
                true,
                ["department" => $department],
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

            Log::error('Department creation failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal membuat departemen",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );
        }
    }

    /**
     * Display the specified department.
     */
    public function show(string $id)
    {
        $department = Department::find($id);
        
        if (!$department) {
            return ResponseWrapper::make(
                "Departemen tidak ditemukan",
                404,
                false,
                null,
                null
            );
        }
        
        return ResponseWrapper::make(
            "Data departemen berhasil ditemukan",
            200,
            true,
            ["department" => $department],
            null
        );
    }

    /**
     * Update the specified department.
     */
    public function update(Request $request, string $id)
    {
        $department = Department::find($id);
        
        if (!$department) {
            return ResponseWrapper::make(
                "Departemen tidak ditemukan",
                404,
                false,
                null,
                null
            );
        }

        try {
            $validated = $request->validate([
                'name' => 'sometimes|required|string|max:100|unique:departments,name,' . $department->id,
                'latitude' => 'sometimes|required|numeric|between:-90,90',
                'longitude' => 'sometimes|required|numeric|between:-180,180',
                'radius_meters' => 'sometimes|required|integer|min:1|max:10000',
            ]);

            DB::beginTransaction();

            $department->update($validated);

            DB::commit();

            return ResponseWrapper::make(
                "Departemen berhasil diperbarui",
                200,
                true,
                ["department" => $department],
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

            Log::error('Department update failed', [
                'department_id' => $department->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal memperbarui departemen",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );
        }
    }

    /**
     * Remove the specified department.
     */
    public function destroy(string $id)
    {
        $department = Department::find($id);
        
        if (!$department) {
            return ResponseWrapper::make(
                "Departemen tidak ditemukan",
                404,
                false,
                null,
                null
            );
        }

        try {
            DB::beginTransaction();

            $department->delete();

            DB::commit();

            return ResponseWrapper::make(
                "Departemen berhasil dihapus",
                200,
                true,
                null,
                null
            );

        } catch (Throwable $e) {
            DB::rollBack();

            Log::error('Department deletion failed', [
                'department_id' => $department->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal menghapus departemen",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );
        }
    }
}