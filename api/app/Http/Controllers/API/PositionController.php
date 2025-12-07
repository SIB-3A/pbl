<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseWrapper;
use App\Http\Controllers\Controller;
use App\Models\Position;
use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Throwable;

class PositionController extends Controller
{
    /**
     * Display a listing of positions.
     */
    public function index()
    {
        $positions = Position::all();
        
        return ResponseWrapper::make(
            "Daftar posisi berhasil diambil",
            200,
            true,
            ["positions" => $positions],
            null
        );
    }

    /**
     * Display the specified position.
     */
    public function show(string $id)
    {
        $position = Position::find($id);
        
        if (!$position) {
            return ResponseWrapper::make(
                "Posisi tidak ditemukan",
                404,
                false,
                null,
                null
            );
        }
        
        return ResponseWrapper::make(
            "Data posisi berhasil ditemukan",
            200,
            true,
            ["position" => $position],
            null
        );
    }

    /**
     * Store a newly created position.
     */
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:100|unique:positions,name',
                'rate_reguler' => 'required|numeric|min:0',
                'rate_overtime' => 'required|numeric|min:0',
            ]);

            DB::beginTransaction();

            $position = Position::create($validated);

            DB::commit();

            return ResponseWrapper::make(
                "Posisi berhasil dibuat",
                201,
                true,
                ["position" => $position],
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

            Log::error('Position creation failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal membuat posisi",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );
        }
    }

    /**
     * Update the specified position.
     */
    public function update(Request $request, string $id)
    {
        $position = Position::find($id);
        
        if (!$position) {
            return ResponseWrapper::make(
                "Posisi tidak ditemukan",
                404,
                false,
                null,
                null
            );
        }

        try {
            $validated = $request->validate([
                'name' => 'sometimes|required|string|max:100|unique:positions,name,' . $position->id,
                'rate_reguler' => 'sometimes|required|numeric|min:0',
                'rate_overtime' => 'sometimes|required|numeric|min:0',
            ]);

            DB::beginTransaction();

            $position->update($validated);

            DB::commit();

            return ResponseWrapper::make(
                "Posisi berhasil diperbarui",
                200,
                true,
                ["position" => $position],
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

            Log::error('Position update failed', [
                'position_id' => $position->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal memperbarui posisi",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );
        }
    }

    /**
     * Remove the specified position.
     */
    public function destroy(string $id)
    {
        $position = Position::find($id);
        
        if (!$position) {
            return ResponseWrapper::make(
                "Posisi tidak ditemukan",
                404,
                false,
                null,
                null
            );
        }

        // Cek apakah posisi masih digunakan oleh karyawan
        $isUsed = Employee::where('position_id', $id)->exists();
        
        if ($isUsed) {
            return ResponseWrapper::make(
                "Posisi tidak dapat dihapus karena masih digunakan oleh karyawan",
                422, // Gunakan 422 untuk validation error
                false,
                null,
                ["error" => "Position is still in use by employees"]
            );
        }

        try {
            DB::beginTransaction();

            $position->delete();

            DB::commit();

            return ResponseWrapper::make(
                "Posisi berhasil dihapus",
                200,
                true,
                null,
                null
            );

        } catch (\Illuminate\Database\QueryException $e) {
            DB::rollBack();
            
            // Tangkap error foreign key constraint
            if ($e->getCode() == 23000) { // SQL integrity constraint violation
                return ResponseWrapper::make(
                    "Posisi tidak dapat dihapus karena masih digunakan oleh karyawan",
                    422,
                    false,
                    null,
                    ["error" => "Foreign key constraint violation"]
                );
            }

            Log::error('Position deletion failed', [
                'position_id' => $position->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal menghapus posisi",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );

        } catch (Throwable $e) {
            DB::rollBack();

            Log::error('Position deletion failed', [
                'position_id' => $position->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal menghapus posisi",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );
        }
    }
    public function show_positions()
    {
        $positions = Position::all([
            "id",
            "name",
            "rate_reguler",
            "rate_overtime",
        ]);
        return ResponseWrapper::make(
            "Positions found",
            200,
            true,
            $positions,
            null,
        );
    }

    public function show_position(string $userId)
    {
        try {
            $userPayroll = Employee::select("user_id", "position_id")
                ->with([
                    "position" => function ($query) {
                        $query->select(
                            "id",
                            "name",
                            "rate_reguler",
                            "rate_overtime",
                        );
                    },
                ])
                ->where("user_id", $userId)
                ->first();

            return ResponseWrapper::make(
                "Sukses",
                200,
                true,
                $userPayroll,
                null,
            );
        } catch (\Error $err) {
            \Log::error("Error getting show_position", $err->getMessage());
            return ResponseWrapper::make(
                "Gagal mengambil data",
                500,
                false,
                null,
                $err->getMessage(),
            );
        }
    }
}