<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $this->dropForeignKeysOnColumn('ulasans', 'pemesanan_id');

        Schema::table('ulasans', function (Blueprint $table) {
            $table->unsignedBigInteger('pemesanan_id')->nullable()->change();
        });

        DB::table('ulasans')
            ->leftJoin('pemesanans', 'ulasans.pemesanan_id', '=', 'pemesanans.id')
            ->whereNotNull('ulasans.pemesanan_id')
            ->whereNull('pemesanans.id')
            ->update(['ulasans.pemesanan_id' => null]);

        Schema::table('ulasans', function (Blueprint $table) {
            $table->foreign('pemesanan_id')
                ->references('id')
                ->on('pemesanans')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        $this->dropForeignKeysOnColumn('ulasans', 'pemesanan_id');

        Schema::table('ulasans', function (Blueprint $table) {
            $table->unsignedBigInteger('pemesanan_id')->nullable(false)->change();
        });

        Schema::table('ulasans', function (Blueprint $table) {
            $table->foreign('pemesanan_id')
                ->references('id')
                ->on('pemesanans')
                ->cascadeOnDelete();
        });
    }

    private function dropForeignKeysOnColumn(string $table, string $column): void
    {
        $driver = DB::connection()->getDriverName();

        if ($driver !== 'mysql') {
            Schema::table($table, function (Blueprint $blueprint) use ($column) {
                $blueprint->dropForeign([$column]);
            });

            return;
        }

        $foreignKeys = DB::select(
            'select CONSTRAINT_NAME as name
             from information_schema.KEY_COLUMN_USAGE
             where TABLE_SCHEMA = database()
               and TABLE_NAME = ?
               and COLUMN_NAME = ?
               and REFERENCED_TABLE_NAME is not null',
            [$table, $column]
        );

        foreach ($foreignKeys as $foreignKey) {
            Schema::table($table, function (Blueprint $blueprint) use ($foreignKey) {
                $blueprint->dropForeign($foreignKey->name);
            });
        }
    }
};
