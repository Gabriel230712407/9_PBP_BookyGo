<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UlasanHelpful extends Model
{
    protected $fillable = [
        'ulasan_id',
        'user_id',
    ];

    public function ulasan()
    {
        return $this->belongsTo(Ulasan::class, 'ulasan_id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}