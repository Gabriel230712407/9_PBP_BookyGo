<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Fasilitas extends Model
{
    protected $table = 'fasilitas';

    protected $fillable = [
        'nama',
    ];

    public function hotels()
    {
        return $this->belongsToMany(
            Hotel::class,
            'hotel_fasilitas',
            'fasilitas_id',
            'hotel_id'
        );
    }

    public function kamars()
    {
        return $this->belongsToMany(
            Kamar::class,
            'kamar_fasilitas',
            'fasilitas_id',
            'kamar_id'
        );
    }
}