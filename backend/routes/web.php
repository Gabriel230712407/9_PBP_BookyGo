<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/storage/{path}', function (string $path) {
    if (Storage::disk('public')->exists($path)) {
        return Storage::disk('public')->response($path);
    }

    $seedFilePath = database_path('seed_files/' . $path);

    abort_unless(is_file($seedFilePath), 404);

    return response()->file($seedFilePath);
})->where('path', '.*');
