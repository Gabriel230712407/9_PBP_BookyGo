<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\HotelController;
use App\Http\Controllers\KamarController;
use App\Http\Controllers\FasilitasController;
use App\Http\Controllers\AddonController;
use App\Http\Controllers\PemesananController;
use App\Http\Controllers\WishlistController;
use App\Http\Controllers\UlasanController;
use App\Http\Controllers\FotoHotelController;
use App\Http\Controllers\FotoKamarController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/hotels', [HotelController::class, 'index']);
Route::get('/hotels/{id}', [HotelController::class, 'show']);

Route::get('/kamars', [KamarController::class, 'index']);
Route::get('/kamars/{id}', [KamarController::class, 'show']);

Route::get('/fasilitas', [FasilitasController::class, 'index']);
Route::get('/addons', [AddonController::class, 'index']);

Route::get('/foto-hotels', [FotoHotelController::class, 'index']);
Route::get('/foto-hotels/{id}', [FotoHotelController::class, 'show']);

Route::get('/foto-kamars', [FotoKamarController::class, 'index']);
Route::get('/foto-kamars/{id}', [FotoKamarController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::apiResource('pemesanans', PemesananController::class);
    Route::apiResource('wishlists', WishlistController::class);
    Route::apiResource('ulasans', UlasanController::class);

    Route::apiResource('hotels', HotelController::class)->except(['index', 'show']);
    Route::apiResource('kamars', KamarController::class)->except(['index', 'show']);
    Route::apiResource('fasilitas', FasilitasController::class)->except(['index']);
    Route::apiResource('addons', AddonController::class)->except(['index']);
    Route::apiResource('foto-hotels', FotoHotelController::class)->except(['index', 'show']);
    Route::apiResource('foto-kamars', FotoKamarController::class)->except(['index', 'show']);
});