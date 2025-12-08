<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('check_clocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee_id')->constrained()->cascadeOnDelete();
            $table->tinyInteger('check_clock_type')->comment('0 = Reguler, 1 = Lembur Khusus');
            $table->date('date');
            $table->time('clock_in')->nullable();
            $table->time('clock_out')->nullable();
            $table->time('overtime_start')->nullable();
            $table->time('overtime_end')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->integer('accuracy_meters')->nullable();
            $table->timestamps();

            $table->unique(['employee_id', 'date', 'check_clock_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('check_clocks');
    }
};