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

use Illuminate\Http\Request;
use App\Models\Pemesanan;
use App\Models\Wishlist;
use App\Models\Ulasan;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::get('/my-pemesanans', [PemesananController::class, 'myBookings']);
    Route::post('/pemesanans', [PemesananController::class, 'store']);
    Route::put('/pemesanans/{pemesanan}', [PemesananController::class, 'update']);
    Route::patch('/pemesanans/{pemesanan}', [PemesananController::class, 'update']);
    Route::delete('/pemesanans/{pemesanan}', [PemesananController::class, 'destroy']);

    Route::get('/profile/stats', function (Request $request) {
        $userId = $request->user()->id;

        return response()->json([
            'login_user_id' => $userId,

            'total_pemesanans_all' => Pemesanan::count(),
            'total_ulasans_all' => Ulasan::count(),
            'total_wishlists_all' => Wishlist::count(),

            'review_count' => Ulasan::where('user_id', $userId)->count(),
            'booked_count' => Pemesanan::where('user_id', $userId)->count(),
            'wishlist_count' => Wishlist::where('user_id', $userId)->count(),
        ]);
    });
});

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

Route::get('/pemesanans', [PemesananController::class, 'index']);
Route::get('/pemesanans/{pemesanan}', [PemesananController::class, 'show']);
Route::apiResource('wishlists', WishlistController::class);
Route::apiResource('ulasans', UlasanController::class);

Route::apiResource('hotels', HotelController::class)->except(['index', 'show']);
Route::apiResource('kamars', KamarController::class)->except(['index', 'show']);
Route::apiResource('fasilitas', FasilitasController::class)->except(['index']);
Route::apiResource('addons', AddonController::class)->except(['index']);
Route::apiResource('foto-hotels', FotoHotelController::class)->except(['index', 'show']);
Route::apiResource('foto-kamars', FotoKamarController::class)->except(['index', 'show']);
