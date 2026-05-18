<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pemesanan extends Model
{
    protected $fillable = [
        'user_id',
        'kamar_id',
        'tgl_checkin',
        'tgl_checkout',
        'status_pesan',
        'metode_bayar',
        'kode_booking',
        'nama',
        'email',
        'no_telp',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function kamar()
    {
        return $this->belongsTo(Kamar::class, 'kamar_id');
    }

    public function ulasan()
    {
        return $this->hasOne(Ulasan::class, 'pemesanan_id');
    }

    public function addons()
    {
        return $this->belongsToMany(
            Addon::class,
            'pemesanan_addons',
            'pemesanan_id',
            'addon_id'
        );
    }

    public function pemesananAddons()
    {
        return $this->hasMany(PemesananAddon::class, 'pemesanan_id');
    }
}