<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use Notifiable;

    protected $fillable = [
        'nama',
        'gender',
        'no_telp',
        'email',
        'password',
        'fotoProfile',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    public function pemesanans()
    {
        return $this->hasMany(Pemesanan::class, 'user_id');
    }

    public function wishlists()
    {
        return $this->hasMany(Wishlist::class, 'user_id');
    }

    public function ulasans()
    {
        return $this->hasMany(Ulasan::class, 'user_id');
    }

    public function pemesananAddons()
    {
        return $this->hasMany(PemesananAddon::class, 'user_id');
    }
}