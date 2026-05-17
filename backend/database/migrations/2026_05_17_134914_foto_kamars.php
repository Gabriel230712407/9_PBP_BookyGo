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
        Schema::create('foto_kamars', function (Blueprint $table) {
            $table->id();

            $table->foreignId('kamar_id')
                ->constrained('kamars')
                ->onDelete('cascade');

            $table->string('path');
            $table->integer('urutan')->default(1);

            $table->timestamps();

            $table->unique(['kamar_id', 'urutan']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('foto_kamars');
    }
};
