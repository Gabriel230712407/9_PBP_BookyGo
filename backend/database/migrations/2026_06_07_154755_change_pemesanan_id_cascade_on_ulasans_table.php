<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('ulasans', function (Blueprint $table) {
            // Drop foreign key lama
            $table->dropForeign(['pemesanan_id']);

            // Buat ulang tanpa cascade
            $table->foreign('pemesanan_id')
                ->references('id')
                ->on('pemesanans')
                ->onDelete('set null');

            // Ubah kolom jadi nullable
            $table->unsignedBigInteger('pemesanan_id')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('ulasans', function (Blueprint $table) {
            $table->dropForeign(['pemesanan_id']);
            $table->foreign('pemesanan_id')
                ->references('id')
                ->on('pemesanans')
                ->onDelete('cascade');
            $table->unsignedBigInteger('pemesanan_id')->nullable(false)->change();
        });
    }
};