<?php

use App\Http\Controllers\API\IzinDashboardController;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\LetterController;

Route::get("/user/{id}", [UserController::class, "show_user"]);
Route::get('/test', function () {
    return response()->json(['status' => 'ok']);
});



Route::get('/letters', [LetterController::class, 'index']);
Route::get('/letters/{id}', [LetterController::class, 'show']);
Route::post('/letters', [LetterController::class, 'store']);
Route::put('/letters/{id}/status', [LetterController::class, 'updateStatus']);
Route::delete('/letters/{id}', [LetterController::class, 'destroy']);

Route::get('/izin-dashboard', IzinDashboardController::class);
Route::get('/export-approved-letters', [IzinDashboardController::class, 'exportApprovedLetters']);




Route::post("/login", [AuthController::class, "login"]);
Route::post("/register", [AuthController::class, "register"])->middleware(
    "auth:sanctum",);
