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
        Schema::table('users', function (Blueprint $table) {
            $table->enum('gender', ['Pria', 'Wanita'])->nullable()->change();
            $table->string('no_telp')->nullable()->change();
            $table->string('foto')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('gender', ['Pria', 'Wanita'])->nullable(false)->change();
            $table->string('no_telp')->nullable(false)->change();
            $table->binary('foto')->nullable()->change();
        });
    }
};
