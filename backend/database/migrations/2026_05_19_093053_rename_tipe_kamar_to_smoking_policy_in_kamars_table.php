<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kamars', function (Blueprint $table) {
            $table->renameColumn('tipe_kamar', 'smoking_policy');
        });

        DB::table('kamars')->update([
            'smoking_policy' => 'non_smoking'
        ]);
    }

    public function down(): void
    {
        Schema::table('kamars', function (Blueprint $table) {
            $table->renameColumn('smoking_policy', 'tipe_kamar');
        });
    }
};