<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ResponseWrapper;
use App\Http\Controllers\Controller;
use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use Throwable;

class EmployeeProfileController extends Controller
{
    /**
     * Update employee profile data (by employee themselves).
     * Only updates: first_name, last_name, gender, address, profile_photo
     */
    public function update(Request $request, string $id)
    {
        // Remove _method field from request (for method spoofing)
        $request->request->remove('_method');
        
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

        // TODO: Add authorization check
        // if ($request->user()->id !== $employee->user_id) {
        //     return ResponseWrapper::make(
        //         "Anda tidak memiliki akses untuk mengubah data ini",
        //         403,
        //         false,
        //         null,
        //         null
        //     );
        // }

        try {
            $validated = $request->validate([
                "first_name" => "sometimes|required|string|max:100",
                "last_name" => "sometimes|required|string|max:100",
                "gender" => "sometimes|required|in:L,P",
                "address" => "sometimes|required|string|max:255",
                "profile_photo" => "sometimes|image|mimes:jpeg,jpg,png|max:2048", // Max 2MB
            ]);

            DB::beginTransaction();

            // Handle profile photo upload
            if ($request->hasFile('profile_photo')) {
                // Delete old photo if exists
                if ($employee->profile_photo) {
                    Storage::disk('public')->delete($employee->profile_photo);
                }

                // Store new photo in storage/app/public/profile_photos
                $path = $request->file('profile_photo')->store('profile_photos', 'public');
                $validated['profile_photo'] = $path;
            }

            $employee->update($validated);

            DB::commit();

            // Load relationships
            $employee->load(['user', 'position', 'department']);

            return ResponseWrapper::make(
                "Informasi pribadi berhasil diperbarui",
                200,
                true,
                ["employee" => $employee],
                null
            );

        } catch (ValidationException $e) {
            DB::rollBack();
            
            return ResponseWrapper::make(
                "Validasi gagal",
                422,
                false,
                null,
                $e->errors()
            );

        } catch (Throwable $e) {
            DB::rollBack();

            Log::error('Employee profile update failed', [
                'employee_id' => $employee->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return ResponseWrapper::make(
                "Gagal memperbarui informasi pribadi",
                500,
                false,
                null,
                ["error" => "Internal server error"]
            );
        }
    }
}