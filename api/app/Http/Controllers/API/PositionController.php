<?php

namespace App\Http\Controllers\API;

use App\Helpers\ResponseWrapper;
use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\Position;
use Illuminate\Http\Request;

class PositionController extends Controller
{
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
