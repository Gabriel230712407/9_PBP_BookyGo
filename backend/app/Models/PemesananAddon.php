<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PemesananAddon extends Model
{
    protected $fillable = [
        'pemesanan_id',
        'addon_id',
        'user_id',
    ];

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class, 'pemesanan_id');
    }

    public function addon()
    {
        return $this->belongsTo(Addon::class, 'addon_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}