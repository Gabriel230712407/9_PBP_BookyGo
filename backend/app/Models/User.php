<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens,Notifiable;

    protected $fillable = [
        'name',
        'gender',
        'no_telp',
        'email',
        'password',
        'foto',
        'fcm_token',
        'google_uid',
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