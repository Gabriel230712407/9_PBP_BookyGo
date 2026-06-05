<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Addon extends Model
{
    protected $fillable = [
        'nama',
        'harga',
    ];

    public function pemesanans()
    {
        return $this->belongsToMany(
            Pemesanan::class,
            'pemesanan_addons',
            'addon_id',
            'pemesanan_id'
        );
    }

    public function pemesananAddons()
    {
        return $this->hasMany(PemesananAddon::class, 'addon_id');
    }
}
