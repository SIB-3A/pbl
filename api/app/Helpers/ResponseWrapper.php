<?php

namespace App\Helpers;

class ResponseWrapper
{
    public static function make(
        string $message,
        int $status,
        bool $success,
        array|null $data,
        array|null $errors,
    ) {
        if (!is_null($errors)) {
            return response()->json(
                [
                    "message" => $message,
                    "data" => $data,
                    "error" => $errors,
                    "success" => $success,
                ],
                $status,
            );
        }
        return response()->json(
            [
                "message" => $message,
                "data" => $data,
                "error" => $errors,
                "success" => $success,
            ],
            $status,
        );
    }
}
