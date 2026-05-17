<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HotelFasilitas extends Model
{
    protected $table = 'hotel_fasilitas';

    protected $fillable = [
        'hotel_id',
        'fasilitas_id',
    ];

    public function hotel()
    {
        return $this->belongsTo(Hotel::class, 'hotel_id');
    }

    public function fasilitas()
    {
        return $this->belongsTo(Fasilitas::class, 'fasilitas_id');
    }
}