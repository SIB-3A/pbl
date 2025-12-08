<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\AttendanceController;
use App\Http\Controllers\API\ScheduleController;
use App\Http\Controllers\API\DepartementController;
use App\Http\Controllers\API\PasswordChangeController;
use App\Http\Controllers\API\PositionController;
use Illuminate\Support\Facades\Route;

Route::get("/user/{id}", [UserController::class, "show_user"])->middleware(
    "auth:sanctum",
);
Route::get("/users", [UserController::class, "show_users"])->middleware(
    "auth:sanctum",
);
Route::get("/departements", [DepartementController::class,"show_departements",])->middleware("auth:sanctum");
Route::get("/positions", [PositionController::class, "show_positions"])->middleware("auth:sanctum");
Route::get("/position/{userId}", [PositionController::class, "show_position"])->middleware("auth:sanctum");

Route::post("/login", [AuthController::class, "login"]);
Route::post("/register", [AuthController::class, "register"])->middleware(
    "auth:sanctum",
);

Route::post("/send-token", [PasswordChangeController::class, "send_token"]);
Route::post("/check-token", [PasswordChangeController::class, "check_token"]);
Route::post("/change-password", [PasswordChangeController::class, "change_password"]);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/absen/status', [AttendanceController::class, 'statusHariIni']);
    Route::post('/absen/in', [AttendanceController::class, 'clockIn']);
    Route::post('/absen/out', [AttendanceController::class, 'clockOut']);
    Route::post('/lembur/in', [AttendanceController::class, 'lemburIn']);
    Route::post('/lembur/out', [AttendanceController::class, 'lemburOut']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::prefix('schedule')->group(function () {
        Route::get('/year/{year?}', [ScheduleController::class, 'getYearSchedule']);
        Route::post('/holiday', [ScheduleController::class, 'addHoliday']);
    });
});