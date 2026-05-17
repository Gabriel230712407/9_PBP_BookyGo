<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('ulasans', function (Blueprint $table) {
            $table->id();

            $table->foreignId('pemesanan_id')
                ->constrained('pemesanans')
                ->onDelete('cascade');

            $table->foreignId('kamar_id')
                ->constrained('kamars')
                ->onDelete('cascade');

            $table->foreignId('user_id')
                ->constrained('users')
                ->onDelete('cascade');

            $table->foreignId('hotel_id')
                ->constrained('hotels')
                ->onDelete('cascade');

            $table->double('rating');
            $table->string('komentar')->nullable();

            $table->timestamps();

            $table->unique('pemesanan_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ulasans');
    }
};
