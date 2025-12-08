<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;

class Holiday extends Model
{
    protected $fillable = ['date', 'name', 'description'];
    protected $dates = ['date'];
    
    protected $casts = [
        'date' => 'date',
    ];

    public function translatedDayOfWeek(): Attribute
    {
        return Attribute::get(function () {
            if (!$this->date) {
                return null;
            }

            $english = $this->date->format('l');
            $days = [
                'Monday'    => 'Senin',
                'Tuesday'   => 'Selasa',
                'Wednesday' => 'Rabu',
                'Thursday'  => 'Kamis',
                'Friday'    => 'Jumat',
                'Saturday'  => 'Sabtu',
                'Sunday'    => 'Minggu',
            ];

            return $days[$english] ?? $english;
        });
    }

    protected $appends = ['translated_day_of_week'];
}