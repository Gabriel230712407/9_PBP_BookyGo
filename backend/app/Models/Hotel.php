<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Hotel extends Model
{
    protected $fillable = [
        'nama',
        'kota',
        'total_rating',
        'alamat',
    ];

    public function kamars()
    {
        return $this->hasMany(Kamar::class, 'hotel_id');
    }

    public function wishlists()
    {
        return $this->hasMany(Wishlist::class, 'hotel_id');
    }

    public function ulasans()
    {
        return $this->hasMany(Ulasan::class, 'hotel_id');
    }

    public function fotoHotels()
    {
        return $this->hasMany(FotoHotel::class, 'hotel_id');
    }

    public function fasilitas()
    {
        return $this->belongsToMany(
            Fasilitas::class,
            'hotel_fasilitas',
            'hotel_id',
            'fasilitas_id'
        );
    }
}