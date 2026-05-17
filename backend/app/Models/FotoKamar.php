<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FotoKamar extends Model
{
    protected $fillable = [
        'kamar_id',
        'path',
        'urutan',
    ];

    public function kamar()
    {
        return $this->belongsTo(Kamar::class, 'kamar_id');
    }
}