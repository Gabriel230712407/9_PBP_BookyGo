<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FotoHotel extends Model
{
    protected $fillable = [
        'hotel_id',
        'path',
        'urutan',
    ];

    public function hotel()
    {
        return $this->belongsTo(Hotel::class, 'hotel_id');
    }
}