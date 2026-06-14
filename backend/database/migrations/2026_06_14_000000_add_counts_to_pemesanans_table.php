<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pemesanans', function (Blueprint $table) {
            $table->unsignedInteger('room_count')->default(1)->after('tgl_checkout');
            $table->unsignedInteger('guest_count')->default(1)->after('room_count');
        });
    }

    public function down(): void
    {
        Schema::table('pemesanans', function (Blueprint $table) {
            $table->dropColumn(['room_count', 'guest_count']);
        });
    }
};
