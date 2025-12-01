<?php

namespace App\Http\Controllers\API;

use App\Helpers\ResponseWrapper;
use App\Models\User;
use App\Http\Controllers\Controller;

class UserController extends Controller
{
    public function show_user(string $id)
    {
        $user = User::with("employee")->find($id);
        if (!$user) {
            return ResponseWrapper::make(
                "User not found",
                404,
                true,
                null,
                null,
            );
        }
        return ResponseWrapper::make("User found", 200, true, $user, null);
    }

    public function show_users()
    {
        $data = User::with("employee")->get();
        return ResponseWrapper::make("User found", 200, true, $data, null);
    }
}
