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
        Schema::create('pemesanans', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained('users')
                ->onDelete('cascade');

            $table->foreignId('kamar_id')
                ->constrained('kamars')
                ->onDelete('cascade');

            $table->date('tgl_checkin');
            $table->date('tgl_checkout');

            $table->enum('status_pesan', [
                'pending',
                'confirmed',
                'cancelled',
                'completed'
            ])->default('pending');

            $table->enum('metode_bayar', [
                'transfer',
                'cash',
                'ewallet'
            ])->nullable();

            $table->string('kode_booking')->unique();
            $table->string('nama');
            $table->string('email');
            $table->string('no_telp');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pemesanans');
    }
};
