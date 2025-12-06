<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\Api\EmployeeController;
use App\Http\Controllers\Api\EmployeeProfileController;
use App\Http\Controllers\Api\EmployeeManagementController;
use App\Http\Controllers\Api\PositionController;
use App\Http\Controllers\Api\DepartmentController;
use Illuminate\Support\Facades\Route;

Route::get("/user/{id}", [UserController::class, "show_user"])->middleware(
    "auth:sanctum",
);
Route::get("/users", [UserController::class, "show_users"])->middleware(
    "auth:sanctum",
);
// Auth routes
Route::post("/login", [AuthController::class, "login"]);
Route::post("/register", [AuthController::class, "register"]);

// Employee routes (read only)
Route::get('employees', [EmployeeController::class, 'index']);
Route::get('employees/{id}', [EmployeeController::class, 'show']);

// Employee profile routes (for logged-in employee)
Route::patch('employee/profile/{id}', [EmployeeProfileController::class, 'update']);

// Employee management routes (for admin only)
// TODO: Add 'auth:sanctum' and 'admin' middleware when login is ready
Route::patch('employee/management/{id}', [EmployeeManagementController::class, 'update']);

// Department routes
Route::get('departments', [DepartmentController::class, 'index']);
Route::get('departments/{id}', [DepartmentController::class, 'show']);

// Department management (admin only)
// TODO: Add 'auth:sanctum' and 'admin' middleware when login is ready
Route::post('departments', [DepartmentController::class, 'store']);
Route::patch('departments/{id}', [DepartmentController::class, 'update']);
Route::delete('departments/{id}', [DepartmentController::class, 'destroy']);

// Positions routes
Route::get('positions', [PositionController::class, 'index']);
Route::get('positions/{id}', [PositionController::class, 'show']);

// Position management (admin only)
// TODO: Add 'auth:sanctum' and 'admin' middleware when login is ready
Route::post('positions', [PositionController::class, 'store']);
Route::patch('positions/{id}', [PositionController::class, 'update']);
Route::delete('positions/{id}', [PositionController::class, 'destroy']);
