<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Department extends Model
{
    protected $table = 'departments';
    protected $fillable = ['name', 'latitude', 'longitude', 'radius_meters'];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    public function employees(): HasMany
    {
        return $this->hasMany(Employee::class);
    }
}