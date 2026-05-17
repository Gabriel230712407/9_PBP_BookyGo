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
        Schema::create('kamars', function (Blueprint $table) {
            $table->id();

            $table->foreignId('hotel_id')
                ->constrained('hotels')
                ->onDelete('cascade');

            $table->string('nama');
            $table->string('tipe_kamar');
            $table->string('jenis_kasur');
            $table->integer('kapasitas');
            $table->double('harga');
            $table->integer('jumlah_ulasan')->default(0);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kamars');
    }
};
