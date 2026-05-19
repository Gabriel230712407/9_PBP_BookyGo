<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kamar extends Model
{
    protected $fillable = [
        'hotel_id',
        'nama',
        'smoking_policy',
        'jenis_kasur',
        'kapasitas',
        'harga',
        'jumlah_ulasan',
    ];

    public function hotel()
    {
        return $this->belongsTo(Hotel::class, 'hotel_id');
    }

    public function pemesanans()
    {
        return $this->hasMany(Pemesanan::class, 'kamar_id');
    }

    public function ulasans()
    {
        return $this->hasMany(Ulasan::class, 'kamar_id');
    }

    public function fotoKamars()
    {
        return $this->hasMany(FotoKamar::class, 'kamar_id');
    }

    public function fasilitas()
    {
        return $this->belongsToMany(
            Fasilitas::class,
            'kamar_fasilitas',
            'kamar_id',
            'fasilitas_id'
        );
    }
}