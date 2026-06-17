<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        DB::table('addons')
            ->whereRaw('LOWER(nama) = ?', ['lauandry'])
            ->update([
                'nama' => 'Laundry',
                'updated_at' => now(),
            ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Intentionally left empty: do not reintroduce the typo on rollback.
    }
};
