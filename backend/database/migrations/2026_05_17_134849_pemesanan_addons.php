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
        Schema::create('pemesanan_addons', function (Blueprint $table) {
            $table->id();

            $table->foreignId('pemesanan_id')
                ->constrained('pemesanans')
                ->onDelete('cascade');

            $table->foreignId('addon_id')
                ->constrained('addons')
                ->onDelete('cascade');

            $table->foreignId('user_id')
                ->constrained('users')
                ->onDelete('cascade');

            $table->timestamps();

            $table->unique(['pemesanan_id', 'addon_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pemesanan_addons');
    }
};
