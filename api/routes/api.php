<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\UserController;
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