<?php

namespace App\Http\Controllers;

use App\Models\Hotel;
use Illuminate\Http\Request;

class HotelController extends Controller
{
    public function index()
    {
        $hotels = Hotel::with(['fasilitas', 'fotoHotels', 'kamars'])
            ->withCount('ulasans')                          // ✅ hitung jumlah ulasan
            ->withAvg('ulasans', 'rating')                  // ✅ hitung rata-rata rating
            ->latest()
            ->get();

        $hotels->transform(function ($hotel) {
            $hotel->total_rating = round($hotel->ulasans_avg_rating ?? 0, 1);
            $hotel->total_review = $hotel->ulasans_count ?? 0;
            return $hotel;
        });

        return response()->json([
            'status' => true,
            'message' => 'Data hotel berhasil diambil',
            'data' => $hotels
        ]);
    }

    public function show($id)
    {
        $hotel = Hotel::with([
            'fasilitas',
            'fotoHotels',
            'kamars.fotoKamars',
            'kamars.fasilitas',
            'ulasans.user'
        ])->find($id);

        if (!$hotel) {
            return response()->json([
                'status' => false,
                'message' => 'Hotel tidak ditemukan'
            ], 404);
        }

        $hotel->total_rating = round($hotel->ulasans->avg('rating') ?? 0, 1);
        $hotel->total_review = $hotel->ulasans->count(); // ✅ bonus: kirim juga total review

        return response()->json([
            'status' => true,
            'message' => 'Detail hotel berhasil diambil',
            'data' => $hotel
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:255',
            'kota' => 'required|string|max:255',
            'alamat' => 'required|string|max:255',
            'total_rating' => 'nullable|numeric',
            'fasilitas_ids' => 'nullable|array',
            'fasilitas_ids.*' => 'exists:fasilitas,id',
        ]);

        $hotel = Hotel::create([
            'nama' => $request->nama,
            'kota' => $request->kota,
            'alamat' => $request->alamat,
            'total_rating' => $request->total_rating ?? 0,
        ]);

        if ($request->has('fasilitas_ids')) {
            $hotel->fasilitas()->sync($request->fasilitas_ids);
        }

        return response()->json([
            'status' => true,
            'message' => 'Hotel berhasil ditambahkan',
            'data' => $hotel->load(['fasilitas', 'fotoHotels'])
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $hotel = Hotel::find($id);

        if (!$hotel) {
            return response()->json([
                'status' => false,
                'message' => 'Hotel tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nama' => 'sometimes|required|string|max:255',
            'kota' => 'sometimes|required|string|max:255',
            'alamat' => 'sometimes|required|string|max:255',
            'total_rating' => 'nullable|numeric',
            'fasilitas_ids' => 'nullable|array',
            'fasilitas_ids.*' => 'exists:fasilitas,id',
        ]);

        $hotel->update($request->only([
            'nama',
            'kota',
            'alamat',
            'total_rating',
        ]));

        if ($request->has('fasilitas_ids')) {
            $hotel->fasilitas()->sync($request->fasilitas_ids);
        }

        return response()->json([
            'status' => true,
            'message' => 'Hotel berhasil diperbarui',
            'data' => $hotel->load(['fasilitas', 'fotoHotels'])
        ]);
    }

    public function destroy($id)
    {
        $hotel = Hotel::find($id);

        if (!$hotel) {
            return response()->json([
                'status' => false,
                'message' => 'Hotel tidak ditemukan'
            ], 404);
        }

        $hotel->delete();

        return response()->json([
            'status' => true,
            'message' => 'Hotel berhasil dihapus'
        ]);
    }
}